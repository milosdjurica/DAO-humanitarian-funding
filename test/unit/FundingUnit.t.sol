// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {RevertTransfer} from "../RevertTransfer.sol";

contract FundingUnitTests is Test {
    uint256 public constant AMOUNT_TO_FUND = 1 ether;
    uint256 public constant SENDER_FUNDS = 100 ether;

    Funding funding;
    TimeLock timeLock;
    DeployAndSetUpContracts deployer;
    RevertTransfer revertTransferContract;

    address payable public USER = payable(makeAddr("USER"));
    address payable public SENDER = payable(makeAddr("SENDER"));
    address public USER_TO_GET_FUNDED = makeAddr("USER_TO_GET_FUNDED");

    event AmountFunded(uint256 indexed amount);
    event MoneyIsSentToUser(address indexed user, uint256 indexed amount);

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,) = deployer.run();
        revertTransferContract = new RevertTransfer();
    }

    // function test_constructor_SetsOwnerCorrectly() public {
    //     vm.startPrank(USER);
    //     Funding fundingTest = new Funding();
    //     assertEq(fundingTest.owner(), USER);
    //     vm.stopPrank();
    // }

    // function test_fallback_BoolSuccessFundsMoneyAndEmits() public {
    //     vm.expectEmit(true, true, true, true);
    //     emit AmountFunded(AMOUNT_TO_FUND);
    //     (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("some data");
    //     assertTrue(success);
    //     assertEq(address(funding).balance, AMOUNT_TO_FUND);
    // }

    // function test_receive_BoolSuccessFundsMoneyAndEmits() public {
    //     vm.expectEmit(true, true, true, true);
    //     emit AmountFunded(AMOUNT_TO_FUND);
    //     (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("");
    //     assertTrue(success);
    //     assertEq(address(funding).balance, AMOUNT_TO_FUND);
    // }

    // function test_fund_RevertIf_CalledByNotOwner() public {
    //     vm.startPrank(USER);
    //     vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
    //     funding.fund(USER, 1 ether);
    //     vm.stopPrank();
    // }

    // function test_fund_RevertIf_ZeroAddress() public {
    //     vm.startPrank(address(timeLock));
    //     vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ZeroAddress.selector));
    //     funding.fund(address(0), AMOUNT_TO_FUND);
    // }

    // function test_fund_RevertIf_AmountIsZero() public {
    //     vm.startPrank(address(timeLock));
    //     vm.expectRevert(abi.encodeWithSelector(Funding.Funding__AmountIsZero.selector));
    //     funding.fund(USER_TO_GET_FUNDED, 0);
    //     vm.stopPrank();
    // }

    // function test_fund_RevertIf_NotEnoughBalance() public {
    //     vm.startPrank(address(timeLock));
    //     vm.expectRevert(abi.encodeWithSelector(Funding.Funding__NotEnoughBalance.selector, 0));
    //     funding.fund(USER_TO_GET_FUNDED, AMOUNT_TO_FUND);
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
    //     emit MoneyIsSentToUser(USER_TO_GET_FUNDED, AMOUNT_TO_FUND);
    //     funding.fund(USER_TO_GET_FUNDED, AMOUNT_TO_FUND);
    //     vm.stopPrank();
    // }

    // modifier fundSuccessfully() {
    //     vm.deal(SENDER, SENDER_FUNDS);
    //     vm.startPrank(SENDER);
    //     // ! * 2 to have enough money for gas
    //     payable(address(funding)).transfer(AMOUNT_TO_FUND * 2);
    //     vm.stopPrank();

    //     vm.startPrank(address(timeLock));
    //     funding.fund(USER_TO_GET_FUNDED, AMOUNT_TO_FUND);
    //     vm.stopPrank();
    //     _;
    // }

    // function test_fund_SendsMoneyToUser() public fundSuccessfully {
    //     assertEq(USER_TO_GET_FUNDED.balance, AMOUNT_TO_FUND);
    // }

    // function test_fund_ChangesWinner() public fundSuccessfully {
    //     assertEq(funding.s_winner(), USER_TO_GET_FUNDED);
    // }
}
