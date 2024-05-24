// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {Funding} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {RevertTransfer} from "../mocks/RevertTransfer.sol";

// TODO -> Check how to use mockCall and mockCallRevert -> https://book.getfoundry.sh/cheatcodes/mock-call
contract FundingFuzzTests is Test {
    DeployAndSetUpContracts deployer;
    TimeLock timeLock;
    Funding funding;
    HelperConfig helperConfig;
    RevertTransfer revertTransferContract;

    event AmountFundedToContract(address indexed user, uint256 indexed amount);
    event UserAddedToArray(address indexed user, uint256 indexed amount);

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,, helperConfig) = deployer.run();
        // (interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit) = helperConfig.activeNetworkConfig();
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
        emit UserAddedToArray(user_, amount_);
        funding.addNewUser(user_, amount_);
        vm.stopPrank();
    }
}
