// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ! Uncomment this line to use console.log
import "forge-std/console2.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Funding is Ownable, VRFConsumerBaseV2 {
    error Funding__ZeroAddress();
    error Funding__AmountIsZero();
    error Funding__ContractBalanceIsZero();
    error Funding__TransferFailed();
    error Funding__ContractStateNotOpen(ContractState);
    error Funding__NoUsersToPick();
    error Funding__NotEnoughTimePassed();
    error Funding__UpkeepNotNeeded(uint256 balance, uint256 usersLength, ContractState);

    ////////////////////
    // * Types 		  //
    ////////////////////
    enum ContractState {
        OPEN,
        CLOSED
    }

    ////////////////////
    // * Variables	  //
    ////////////////////
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] public s_users;
    mapping(address => uint256) public s_toBeFunded;
    address public s_recentlyChosenUser;

    uint256 private s_lastTimestamp;
    ContractState private s_contractState;

    ////////////////////
    // * Events 	  //
    ////////////////////
    event AmountFundedToContract(address indexed sender, uint256 indexed amount);
    event UserAddedToArray(address indexed user, uint256 indexed amount);
    event MoneyIsSentToUser(address indexed userToFund, uint256 indexed amount);

    ////////////////////
    // * Modifiers 	  //
    ////////////////////

    constructor(
        uint256 interval_,
        address vrfCoordinator_,
        bytes32 gasLane_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_
    ) Ownable(msg.sender) VRFConsumerBaseV2(vrfCoordinator_) {
        i_interval = interval_;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator_);
        i_gasLane = gasLane_;
        i_subscriptionId = subscriptionId_;
        i_callbackGasLimit = callbackGasLimit_;
        s_contractState = ContractState.OPEN;
        s_lastTimestamp = block.timestamp;
    }

    fallback() external payable {
        sendMoneyToContract();
    }

    receive() external payable {
        sendMoneyToContract();
    }

    function sendMoneyToContract() public payable {
        if (msg.value == 0) revert Funding__AmountIsZero();
        emit AmountFundedToContract(msg.sender, msg.value);
    }

    function addNewUser(address newUser_, uint256 amount_) external onlyOwner {
        if (newUser_ == address(0)) revert Funding__ZeroAddress();
        if (amount_ <= 0) revert Funding__AmountIsZero();
        // ! TODO -> Check in REMIX if it is more gas efficient to ->
        // ! store contractState in local variable and then use it in next line
        // TODO -> Also check in REMIX what costs more gas, getting public variable or private variable with getter
        if (s_contractState != ContractState.OPEN) revert Funding__ContractStateNotOpen(s_contractState);

        if (s_toBeFunded[newUser_] == 0) s_users.push(payable(newUser_));
        s_toBeFunded[newUser_] += amount_;
        emit UserAddedToArray(newUser_, amount_);
    }

    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        if ((block.timestamp - s_lastTimestamp) < i_interval) revert Funding__NotEnoughTimePassed();
        if (address(this).balance == 0) revert Funding__ContractBalanceIsZero();
        if (s_users.length == 0) revert Funding__NoUsersToPick();
        if (s_contractState != ContractState.OPEN) revert Funding__ContractStateNotOpen(s_contractState);

        return (true, "0x0");
    }

    function performUpkeep(bytes calldata /*performData*/ ) external {
        checkUpkeep("");

        // ! TODO -> check if this should be above checkUpkeep ?
        s_contractState = ContractState.CLOSED;
        i_vrfCoordinator.requestRandomWords(
            i_gasLane, // gas lane
            i_subscriptionId, // id
            REQUEST_CONFIRMATIONS, // how many blocks should pass
            i_callbackGasLimit, // gas limit
            NUM_WORDS // number of random numbers we get back
        );
    }

    function fulfillRandomWords(uint256, /*requestId */ uint256[] memory randomWords) internal override {
        uint256 balanceOfContract = address(this).balance;
        uint256 totalNumberOfUsers = s_users.length;
        uint256 indexOfWinner = randomWords[0] % totalNumberOfUsers;
        address payable winner = s_users[indexOfWinner];
        uint256 moneyNeeded = s_toBeFunded[winner];
        uint256 moneyToSend = 0;

        if (moneyNeeded > balanceOfContract) {
            s_toBeFunded[winner] -= balanceOfContract;
            moneyToSend = balanceOfContract;
        } else {
            s_toBeFunded[winner] = 0;
            // ! Remove winner -> put last one on his place and pop last one because now there are 2
            s_users[indexOfWinner] = s_users[totalNumberOfUsers - 1];
            s_users.pop();
            moneyToSend = moneyNeeded;
        }

        s_lastTimestamp = block.timestamp;
        s_recentlyChosenUser = winner;
        s_contractState = ContractState.OPEN;
        emit MoneyIsSentToUser(winner, moneyToSend);

        // ! TODO -> Check if moneyToSend logic is good!!!
        (bool success,) = winner.call{value: moneyToSend}("");
        if (!success) revert Funding__TransferFailed();
    }

    function getUserByIndex(uint256 index_) external view returns (address) {
        return s_users[index_];
    }

    function getAmountThatUserNeeds(address user_) external view returns (uint256) {
        return s_toBeFunded[user_];
    }

    function getContractState() external view returns (ContractState) {
        return s_contractState;
    }

    function getSubId() external view returns (uint64) {
        return i_subscriptionId;
    }

    function getLatestTimestamp() external view returns (uint256) {
        return s_lastTimestamp;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentlyChosenUser;
    }
}
