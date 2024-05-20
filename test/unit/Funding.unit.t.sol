// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";

contract FundingUnitTests is Test {
    uint256 public constant AMOUNT_TO_FUND = 1 ether;
    uint256 public constant SENDER_FUNDS = 100 ether;

    Funding funding;
    TimeLock timeLock;
    DeployAndSetUpContracts deployer;

    address payable public USER = payable(makeAddr("USER"));
    address payable public SENDER = payable(makeAddr("SENDER"));
    address public USER_TO_GET_FUNDED = makeAddr("USER_TO_GET_FUNDED");

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,) = deployer.run();
    }

    function test_fund_RevertIf_CalledByNotOwner() public {
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        funding.fund(USER, 1 ether);
        vm.stopPrank();
    }

    function test_fund_RevertIf_ZeroAddress() public {
        vm.startPrank(address(timeLock));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ZeroAddress.selector));
        funding.fund(address(0), 1 ether);
    }

    function test_fund_RevertIf_AmountIsZero() public {
        vm.startPrank(address(timeLock));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__AmountIsZero.selector));
        funding.fund(USER_TO_GET_FUNDED, 0);
        vm.stopPrank();
    }

    function test_fund_RevertIf_NotEnoughBalance() public {
        vm.startPrank(address(timeLock));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__NotEnoughBalance.selector, 0));
        funding.fund(USER_TO_GET_FUNDED, 1 ether);
        vm.stopPrank();
    }

    function test_fund_FundsSuccessfully() public {
        vm.deal(SENDER, SENDER_FUNDS);
        vm.startPrank(SENDER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND * 2);
        vm.stopPrank();

        vm.startPrank(address(timeLock));
        funding.fund(USER_TO_GET_FUNDED, 1 ether);
        vm.stopPrank;
    }
}
