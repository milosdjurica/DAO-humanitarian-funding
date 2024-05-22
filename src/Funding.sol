// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ! Uncomment this line to use console.log
// import "hardhat/console.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Funding is Ownable, VRFConsumerBaseV2 {
    error Funding__ZeroAddress();
    error Funding__AmountIsZero();
    error Funding__NotEnoughBalance(uint256 balance);
    error Funding__TransferFailed();
    error Funding__ContractStateNotOpen(ContractState);

    ////////////////////
    // * Types 		  //
    ////////////////////
    enum ContractState {
        OPEN,
        CALCULATING
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

    address payable[] private s_users;
    mapping(address => uint256) s_toBeFunded;

    address public s_recentlyChosenUser;
    ContractState private s_contractState;

    ////////////////////
    // * Events 	  //
    ////////////////////
    event AmountFunded(uint256 indexed amount);
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
    }

    fallback() external payable {
        emit AmountFunded(msg.value);
    }

    receive() external payable {
        emit AmountFunded(msg.value);
    }

    function addNewUser(address newUser_, uint256 amount_) external onlyOwner {
        if (newUser_ == address(0)) revert Funding__ZeroAddress();
        if (amount_ <= 0) revert Funding__AmountIsZero();
        // TODO check if this is good !!
        if (s_contractState != ContractState.OPEN) revert Funding__ContractStateNotOpen(s_contractState);

        if (s_toBeFunded[newUser_] == 0) s_users.push(payable(newUser_));
        s_toBeFunded[newUser_] += amount_;
    }

    function giveFundsToUser() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, // gas lane
            i_subscriptionId, // id
            REQUEST_CONFIRMATIONS, // how many blocks should pass
            i_callbackGasLimit, // gas limit
            NUM_WORDS // number of random numbers we get back
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        // ! TODO -> Do the funding logic here !!!!!!!!!!!!!!!!!!!!!!!!!!!

        uint256 totalNumberOfUsers = s_users.length;
        uint256 indexOfWinner = randomWords[0] % totalNumberOfUsers;
        address payable winner = s_users[indexOfWinner];
        s_recentlyChosenUser = winner;
        // TODO -> update this when funding or remove this completely???
        // TODO -> remove user from array if it is funded completely
        // TODO -> emit that money is sent to user

        (bool success,) = s_recentlyChosenUser.call{value: address(this).balance}("");
        if (!success) revert Funding__TransferFailed();
    }

    // TODO ->
    // - DAO users vote who can get the chance to get money and how much money we put in them
    // - Every 24h new random winner is picked and ALL money from contract is sent or max needed for user.
    // - Remaining stays at the contract and is given to the next winner
    // - Picking winner is random

    function fund(address userToFund_) public onlyOwner {
        uint256 balanceOfContract = address(this).balance;
        if (userToFund_ == address(0)) revert Funding__ZeroAddress();
        if (balanceOfContract <= 0) revert Funding__AmountIsZero();

        // ! If balance -> s_toBeFunded[user] ===> then just give that toBeFunded value, not everything
        // ! s_toBeFunded -= balance (or === 0)

        s_recentlyChosenUser = userToFund_;
        emit MoneyIsSentToUser(userToFund_, balanceOfContract);
        (bool success,) = userToFund_.call{value: balanceOfContract}("");
        if (!success) revert Funding__TransferFailed();
    }
}
