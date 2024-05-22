// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {RevertTransfer} from "../RevertTransfer.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundingUnitTests is Test {
    uint256 constant AMOUNT_TO_FUND = 1 ether;
    uint256 constant SENDER_FUNDS = 100 ether;

    Funding funding;
    TimeLock timeLock;
    DeployAndSetUpContracts deployer;
    RevertTransfer revertTransferContract;

    HelperConfig helperConfig;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address payable USER = payable(makeAddr("USER"));
    address payable SENDER = payable(makeAddr("SENDER"));
    address USER_TO_ADD = makeAddr("USER_TO_ADD");

    event AmountFunded(address indexed sender, uint256 indexed amount);
    event MoneyIsSentToUser(address indexed user, uint256 indexed amount);

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,, helperConfig) = deployer.run();
        (interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit) = helperConfig.activeNetworkConfig();
        revertTransferContract = new RevertTransfer();
    }

    function test_constructor_SetsOwnerCorrectly() public {
        vm.startPrank(USER);
        Funding fundingTest = new Funding(interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        assertEq(fundingTest.owner(), USER);
        vm.stopPrank();
    }

    function test_owner_TimeLockIsOwner() public view {
        assertEq(funding.owner(), address(timeLock));
    }

    function test_fallback_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFunded(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("some data");
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND);
    }

    function test_receive_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFunded(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("");
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND);
    }

    function test_sendMoneyToContract_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFunded(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}(abi.encodeWithSignature("sendMoneyToContract()"));
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND);
    }

    function test_addNewUser_RevertIf_CalledByNotOwner() public {
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        funding.addNewUser(USER, 1 ether);
        vm.stopPrank();
    }

    function test_addNewUser_RevertIf_ZeroAddress() public {
        vm.startPrank(address(timeLock));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ZeroAddress.selector));
        funding.addNewUser(address(0), AMOUNT_TO_FUND);
    }

    function test_addNewUser_RevertIf_AmountIsZero() public {
        vm.startPrank(address(timeLock));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__AmountIsZero.selector));
        funding.addNewUser(USER_TO_ADD, 0);
        vm.stopPrank();
    }

    // function test_fund_RevertIf_NotEnoughBalance() public {
    //     vm.startPrank(address(timeLock));
    //     vm.expectRevert(abi.encodeWithSelector(Funding.Funding__NotEnoughBalance.selector, 0));
    //     funding.fund(USER_TO_ADD, AMOUNT_TO_FUND);
    //     vm.stopPrank();
    // }

    // function test_fund_RevertIf_TransferFailed() public {
    //     vm.deal(SENDER, SENDER_FUNDS);
    //     vm.startPrank(SENDER);
    //     payable(address(funding)).transfer(AMOUNT_TO_FUND * 2);
    //     vm.stopPrank();

    //     vm.startPrank(address(timeLock));
    //     vm.expectRevert(abi.encodeWithSelector(Funding.Funding__TransferFailed.selector));
    //     funding.fund(address(revertTransferContract), AMOUNT_TO_FUND);
    //     vm.stopPrank();
    // }

    // function test_fund_EmitsEvent() public {
    //     vm.deal(SENDER, SENDER_FUNDS);
    //     vm.startPrank(SENDER);
    //     // ! * 2 to have enough money for gas
    //     payable(address(funding)).transfer(AMOUNT_TO_FUND * 2);
    //     vm.stopPrank();

    //     vm.startPrank(address(timeLock));
    //     vm.expectEmit(true, true, true, true);
    //     emit MoneyIsSentToUser(USER_TO_ADD, AMOUNT_TO_FUND);
    //     funding.fund(USER_TO_ADD, AMOUNT_TO_FUND);
    //     vm.stopPrank();
    // }

    // modifier fundSuccessfully() {
    //     vm.deal(SENDER, SENDER_FUNDS);
    //     vm.startPrank(SENDER);
    //     // ! * 2 to have enough money for gas
    //     payable(address(funding)).transfer(AMOUNT_TO_FUND * 2);
    //     vm.stopPrank();

    //     vm.startPrank(address(timeLock));
    //     funding.fund(USER_TO_ADD, AMOUNT_TO_FUND);
    //     vm.stopPrank();
    //     _;
    // }

    // function test_fund_SendsMoneyToUser() public fundSuccessfully {
    //     assertEq(USER_TO_ADD.balance, AMOUNT_TO_FUND);
    // }

    // function test_fund_ChangesWinner() public fundSuccessfully {
    //     assertEq(funding.s_winner(), USER_TO_ADD);
    // }
}
