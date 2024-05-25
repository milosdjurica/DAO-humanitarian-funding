// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {Funding} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {RevertTransfer} from "../mocks/RevertTransfer.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

// TODO -> Check how to use mockCall and mockCallRevert -> https://book.getfoundry.sh/cheatcodes/mock-call
contract FundingFuzzTests is Test {
    uint256 constant AMOUNT_TO_FUND = 1 ether;

    address payable USER = payable(makeAddr("USER"));
    address payable USER_TO_ADD = payable(makeAddr("USER_TO_ADD"));

    DeployAndSetUpContracts deployer;
    TimeLock timeLock;
    Funding funding;
    HelperConfig helperConfig;
    RevertTransfer revertTransferContract;
    address vrfCoordinator;

    event AmountFundedToContract(address indexed sender, uint256 indexed amount);
    event ArrayOfUsersUpdated(address indexed user, uint256 indexed amount);
    event MoneyIsSentToUser(address indexed user, uint256 indexed amount);

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,, helperConfig) = deployer.run();
        (, vrfCoordinator,,,) = helperConfig.activeNetworkConfig();
        revertTransferContract = new RevertTransfer();
    }

    function testFuzz_constructor_InitsCorrectly(
        uint256 interval_,
        address vrfCoordinator_,
        bytes32 gasLane_,
        uint64 subscriptionId_,
        uint32 callbackGasLimit_
    ) public {
        Funding testFunding = new Funding(interval_, vrfCoordinator_, gasLane_, subscriptionId_, callbackGasLimit_);
        assert(testFunding.getContractState() == Funding.ContractState.OPEN);
        assertEq(testFunding.getLatestTimestamp(), block.timestamp);
    }

    function testFuzz_Fallback_BoolSuccessFudsMoneyAndEmits(address sender_, uint256 amount_) public {
        vm.assume(amount_ != 0);
        vm.prank(sender_);
        vm.deal(sender_, amount_);

        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(sender_, amount_);
        (bool success,) = address(funding).call{value: amount_}("some data");
        vm.stopPrank();
        assertTrue(success);
        assertEq(address(funding).balance, amount_);
    }

    function testFuzz_Receive_BoolSuccessFudsMoneyAndEmits(address sender_, uint256 amount_) public {
        vm.assume(amount_ != 0);
        vm.prank(sender_);
        vm.deal(sender_, amount_);

        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(sender_, amount_);
        (bool success,) = address(funding).call{value: amount_}("some data");
        vm.stopPrank();
        assertTrue(success);
        assertEq(address(funding).balance, amount_);
    }

    function testFuzz_sendMoneyToContract_BoolSuccessFudsMoneyAndEmits(address sender_, uint256 amount_) public {
        vm.assume(amount_ != 0);
        vm.prank(sender_);
        vm.deal(sender_, amount_);

        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(sender_, amount_);
        (bool success,) = address(funding).call{value: amount_}(abi.encodeWithSignature("sentMoneyToContract()"));
        vm.stopPrank();
        assertTrue(success);
        assertEq(address(funding).balance, amount_);
    }

    function testFuzz_addNewUser_AddsSuccessfully(address user_, uint256 amount_) public {
        vm.assume(user_ != address(0));
        vm.assume(amount_ != 0);

        vm.startPrank(address(timeLock));
        vm.expectEmit(true, true, true, true);
        emit ArrayOfUsersUpdated(user_, amount_);
        funding.addNewUser(user_, amount_);
        vm.stopPrank();

        assertEq(funding.getAmountThatUserNeeds(user_), amount_);
        assertEq(funding.getUserByIndex(0), user_);
    }

    function testFuzz_fulfillRandomWords_FulfillsWithRandomNumber(uint256 randomNumber_) public {
        hoax(USER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND);
        vm.startPrank(address(timeLock));
        funding.addNewUser(USER_TO_ADD, AMOUNT_TO_FUND * 2);
        vm.stopPrank();

        vm.startPrank(vrfCoordinator);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = randomNumber_;

        vm.expectEmit(true, true, true, true);
        emit MoneyIsSentToUser(USER_TO_ADD, AMOUNT_TO_FUND);
        funding.rawFulfillRandomWords(1, randomWords);
        vm.stopPrank();

        assert(funding.getContractState() == Funding.ContractState.OPEN);
        assertEq(funding.getLatestTimestamp(), block.timestamp);
        assertEq(funding.getRecentWinner(), USER_TO_ADD);
        assertEq(funding.getAmountThatUserNeeds(USER_TO_ADD), AMOUNT_TO_FUND);
        assertEq(USER_TO_ADD.balance, AMOUNT_TO_FUND);
        assertEq(address(funding).balance, 0);
    }
}
