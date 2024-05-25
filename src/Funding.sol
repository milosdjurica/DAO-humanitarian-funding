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
    uint16 private constant REQUEST_BLOCK_CONFIRMATIONS = 3;
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
    event ArrayOfUsersUpdated(address indexed user, uint256 indexed amount);
    event MoneyIsSentToUser(address indexed userToFund, uint256 indexed amount);

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

    /**
     * @notice Sends money to the contract and logs the amount funded
     * @dev Reverts with Funding__AmountIsZero if the sent amount is zero
     * @dev Emits an {AmountFundedToContract} event on successful funding
     */
    function sendMoneyToContract() public payable {
        if (msg.value == 0) revert Funding__AmountIsZero();
        emit AmountFundedToContract(msg.sender, msg.value);
    }

    /**
     * @notice This function should be called in 2 cases. To add a new user to the funding list with the specified amount, or update amount to fund for an existing user. This function can only be called by the OWNER, which is the TimeLock contract controlled by the DAO
     * @dev Reverts with Funding__ZeroAddress if the `user_` address is zero.
     * @dev Reverts with Funding__AmountIsZero if the `amount_` is zero or less
     * @dev Reverts with Funding__ContractStateNotOpen if the contract state is NOT `OPEN`
     * @dev Emits a {ArrayOfUsersUpdated} event on successful addition of the user
     * @param user_ The address of the user to be added or updated
     * @param amount_ The amount needed to be funded for the user
     */
    function addNewUser(address user_, uint256 amount_) external onlyOwner {
        if (user_ == address(0)) revert Funding__ZeroAddress();
        if (amount_ <= 0) revert Funding__AmountIsZero();
        // ! Commented lines should be more gas efficient
        // ContractState localState = s_contractState;
        // if (localState != ContractState.OPEN) revert Funding__ContractStateNotOpen(localState);
        if (s_contractState != ContractState.OPEN) revert Funding__ContractStateNotOpen(s_contractState);

        if (s_toBeFunded[user_] == 0) s_users.push(payable(user_));
        s_toBeFunded[user_] = amount_;
        emit ArrayOfUsersUpdated(user_, amount_);
    }

    /**
     * @notice Checks if the upkeep is needed when calling `performUpkeep`
     * @dev Reverts with Funding__NotEnoughTimePassed if the required time interval has not passed
     * @dev Reverts with Funding__ContractBalanceIsZero if the contract balance is zero
     * @dev Reverts with Funding__NoUsersToPick if there are no users that need money
     * @dev Reverts with Funding__ContractStateNotOpen if the contract state is NOT `OPEN`
     * @return upkeepNeeded Boolean indicating whether the upkeep is needed. This is always true, because in other cases function reverts
     * @return performData Data to be used in performUpkeep function. Always returns "0x0", because this value is not needed in performUpkeep function
     */
    function checkUpkeep(bytes memory /* checkData */ )
        internal
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        if ((block.timestamp - s_lastTimestamp) < i_interval) revert Funding__NotEnoughTimePassed();
        if (address(this).balance == 0) revert Funding__ContractBalanceIsZero();
        if (s_users.length == 0) revert Funding__NoUsersToPick();
        if (s_contractState != ContractState.OPEN) revert Funding__ContractStateNotOpen(s_contractState);

        return (true, "0x0");
    }

    /**
     * @notice Performs the upkeep required to proceed with the contract's operations
     * @dev Calls `checkUpkeep` to verify if the upkeep is needed
     * @dev Sets the contract state to `CLOSED`. This is to prevent adding new users while contract is picking "winner"
     * @dev Requests random words from Chainlink VRF
     */
    function performUpkeep(bytes calldata /*performData*/ ) external {
        checkUpkeep("");

        s_contractState = ContractState.CLOSED;
        i_vrfCoordinator.requestRandomWords(
            i_gasLane, i_subscriptionId, REQUEST_BLOCK_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS
        );
    }

    /**
     * @notice Fulfills the random words (numbers) request and distributes funds to the winner
     * @notice There are 2 cases that have to be taken into consideration. First case is that user needs more funds than the contract currently has. In that case we give all funds to the user and keep him in the array. Second case is when the contract has more money than the user needs. In that case we give user funds that he needs and remove him from the array. Contract keeps extra funds for the next iteration
     * @dev Calculates the winner based on the provided random words (numbers)
     * @dev Updates the contract state to the `OPEN`
     * @dev Updates the balance of contract
     * @dev Updates the user needed balance and potentially removes user from array (if given enough funds)
     * @dev Updates the latest timestamp when winner is picked
     * @dev Updates recent winner
     * @dev Emits a {MoneyIsSentToUser} event to indicate the transfer of funds to the winner
     * @dev Reverts with `Funding__TransferFailed` if the fund transfer fails
     * @param randomWords An array containing the generated random words (numbers) used to determine the winner
     */
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

        (bool success,) = winner.call{value: moneyToSend}("");
        if (!success) revert Funding__TransferFailed();
    }

    /**
     * @notice This function is used to retrieve the address of the user at the specified index in the array of users
     * @param index_ The index of the user in the array
     * @return The address of the user at the specified index
     */
    function getUserByIndex(uint256 index_) external view returns (address) {
        return s_users[index_];
    }

    /**
     * @notice This function is used to retrieve the amount that a specific user needs to be funded
     * @param user_ The address of the user
     * @return The amount that the user needs to be funded
     */
    function getAmountThatUserNeeds(address user_) external view returns (uint256) {
        return s_toBeFunded[user_];
    }

    /**
     * @notice This function is used to retrieve the current state of the contract
     * @return The current state of the contract
     */
    function getContractState() external view returns (ContractState) {
        return s_contractState;
    }

    /**
     * @notice This function is used to retrieve the subscription ID used for Chainlink VRF requests
     * @return The subscription ID
     */
    function getSubId() external view returns (uint64) {
        return i_subscriptionId;
    }

    /**
     * @notice This function is used to retrieve the latest timestamp when the winner was picked
     * @return The timestamp of the most recent operation
     */
    function getLatestTimestamp() external view returns (uint256) {
        return s_lastTimestamp;
    }

    /**
     * @notice This function is used to retrieve the address of the most recent winner of a selection process
     * @return The address of the most recent winner
     */
    function getRecentWinner() external view returns (address) {
        return s_recentlyChosenUser;
    }
}
