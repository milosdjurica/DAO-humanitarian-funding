// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {RevertTransfer} from "../mocks/RevertTransfer.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

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

    event UserAddedToArray(address indexed user, uint256 indexed amount);
    event AmountFundedToContract(address indexed sender, uint256 indexed amount);
    event MoneyIsSentToUser(address indexed user, uint256 indexed amount);
    event RandomWordsRequested(
        bytes32 indexed keyHash,
        uint256 requestId,
        uint256 preSeed,
        uint64 indexed subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords,
        address indexed sender
    );

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock,, funding,, helperConfig) = deployer.run();
        (interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit) = helperConfig.activeNetworkConfig();
        revertTransferContract = new RevertTransfer();
    }

    // TODO -> maybe change variables to internal in order to test them with harness contracts
    function test_constructor_SetsOwnerCorrectly() public {
        vm.startPrank(USER);
        Funding fundingTest = new Funding(interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        assertEq(fundingTest.owner(), USER, "Owner on Test Funding Contract should be USER");
        vm.stopPrank();
    }

    function test_constructor_InitsWithStateOpen() public view {
        assert(funding.getContractState() == Funding.ContractState.OPEN);
    }

    // TODO -> maybe ADD STRING DESCRIPTION TO ALL ASSERT EQUALS
    function test_owner_TimeLockIsOwner() public view {
        assertEq(funding.owner(), address(timeLock));
    }

    function test_fallback_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("some data");
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND);
    }

    function test_receive_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}("");
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND);
    }

    function test_sendMoneyToContract_BoolSuccessFundsMoneyAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit AmountFundedToContract(address(this), AMOUNT_TO_FUND);
        (bool success,) = address(funding).call{value: AMOUNT_TO_FUND}(abi.encodeWithSignature("sendMoneyToContract()"));
        assertTrue(success);
        assertEq(address(funding).balance, AMOUNT_TO_FUND, "");
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

    function test_addNewUser_RevertIf_ContractStateIsNotOpen() public {
        vm.startPrank(address(timeLock));
        // ! Manually changing storage value of s_contractState
        // ! vm.store(contractAddr, storageSlot, valueToStore);
        vm.store(address(funding), bytes32(uint256(5)), bytes32(uint256(Funding.ContractState.CLOSED)));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ContractStateNotOpen.selector, 1));
        funding.addNewUser(USER_TO_ADD, AMOUNT_TO_FUND);
        vm.stopPrank();
    }

    function test_addNewUser_AddsUserSuccessfully() public {
        vm.startPrank(address(timeLock));
        vm.expectEmit(true, true, true, true);
        emit UserAddedToArray(USER_TO_ADD, AMOUNT_TO_FUND);
        funding.addNewUser(USER_TO_ADD, AMOUNT_TO_FUND);
        vm.stopPrank();
        assertEq(funding.getAmountThatUserNeeds(USER_TO_ADD), AMOUNT_TO_FUND);
        assertEq(funding.getUserByIndex(0), USER_TO_ADD);
    }

    function test_checkUpkeep_RevertIf_NotEnoughTimePassed() public {
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__NotEnoughTimePassed.selector));
        funding.checkUpkeep("");
    }

    function test_checkUpkeep_RevertIf_ContractBalanceIsZero() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + interval + 1);
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ContractBalanceIsZero.selector));
        funding.checkUpkeep("");
    }

    function test_checkUpkeep_RevertIf_UsersArrayIsEmpty() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + interval + 1);
        hoax(USER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND);
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__NoUsersToPick.selector));
        funding.checkUpkeep("");
    }

    function test_checkUpkeep_RevertIf_StateIsNotOpen() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + interval + 1);
        hoax(USER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND);
        vm.startPrank(address(timeLock));
        funding.addNewUser(USER, AMOUNT_TO_FUND);
        vm.stopPrank();
        vm.store(address(funding), bytes32(uint256(5)), bytes32(uint256(1)));
        vm.expectRevert(abi.encodeWithSelector(Funding.Funding__ContractStateNotOpen.selector, 1));
        funding.checkUpkeep("");
    }

    function test_checkUpkeep_PassesSuccessfully() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + interval + 1);
        hoax(USER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND);
        vm.startPrank(address(timeLock));
        funding.addNewUser(USER_TO_ADD, AMOUNT_TO_FUND);
        vm.stopPrank();

        (bool success, bytes memory data) = funding.checkUpkeep("");
        assertTrue(success);
        assertEq(data, "0x0");
    }

    function test_performUpkeep_PassesSuccessfully() public {
        // vm.mockCall(address(funding), abi.encodeWithSelector(funding.checkUpkeep.selector, ""), abi.encode(true, "0x0"));

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + interval + 1);
        hoax(USER);
        payable(address(funding)).transfer(AMOUNT_TO_FUND);
        vm.startPrank(address(timeLock));
        funding.addNewUser(USER_TO_ADD, AMOUNT_TO_FUND);
        vm.stopPrank();

        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, 3 ether);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, address(funding));

        vm.expectEmit(true, true, true, true);
        emit RandomWordsRequested(
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, 1, 100, 1, 3, 5000, 1, address(funding)
        );
        funding.performUpkeep("");
        assert(funding.getContractState() == Funding.ContractState.CLOSED);
    }

    function test_fulfillRandomWords_FundsAccountThatNeedsMore() public {}
    function test_fulfillRandomWords_FundsAccountCompletely() public {}

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
