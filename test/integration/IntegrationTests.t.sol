// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {VotingToken} from "../../src/VotingToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.s.sol";
import {Constants} from "../../script/Constants.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

contract IntegrationTests is Test, Constants {
    uint256 public constant AMOUNT_NEEDED = 1 ether;
    uint256 public constant SENDER_FUNDS = 100 ether;

    VotingToken votingToken;
    TimeLock timeLock;
    MyGovernor myGovernor;
    Funding funding;
    DeployAndSetUpContracts deployer;
    HelperConfig helperConfig;

    address vrfCoordinator;
    uint256 interval;

    address payable public USER = payable(makeAddr("USER"));
    address payable public SENDER = payable(makeAddr("SENDER"));
    address public USER_TO_ADD = makeAddr("USER_TO_ADD");
    address public firstVoter;

    address[] public proposers;
    address[] public executors;

    address[] public targets;
    uint256[] public values;
    bytes[] public calldatas;

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (votingToken, timeLock, myGovernor, funding, firstVoter, helperConfig) = deployer.run();
        (interval, vrfCoordinator,,,) = helperConfig.activeNetworkConfig();
    }

    // ! Send money to funding contract
    function sendMoneyToFundingContract() internal {
        vm.deal(SENDER, SENDER_FUNDS);
        vm.startPrank(SENDER);
        payable(address(funding)).transfer(AMOUNT_NEEDED * 2);
        vm.stopPrank();
    }

    // ! Give the right to the firstVoter to cast a vote
    function enableVoterToCastVote(address _tokenHolder, address _userToVote) internal {
        vm.startPrank(_tokenHolder);
        votingToken.delegate(_userToVote);
        vm.stopPrank();
    }

    // ! Move time
    function moveTime(uint256 _amount) internal {
        vm.warp(block.timestamp + _amount + 1);
        vm.roll(block.number + _amount + 1);
    }

    function test_votingToken_mint_MintsTokensToNewUser() public {
        sendMoneyToFundingContract();
        // ! Delegate tokens to voter
        enableVoterToCastVote(firstVoter, firstVoter);

        string memory description = "Description";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("mint(address,uint256)", USER_TO_ADD, AMOUNT_NEEDED);
        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(votingToken));

        // ! Propose to DAO
        uint256 proposalId = myGovernor.propose(targets, values, calldatas, description);
        console2.log("Proposal state when proposing: ", uint256(myGovernor.state(proposalId)));
        moveTime(VOTING_DELAY);
        console2.log("Proposal state after proposing: ", uint256(myGovernor.state(proposalId)));

        // ! Voting
        uint8 voteWay = 1;
        vm.startPrank(firstVoter);
        myGovernor.castVote(proposalId, voteWay);
        moveTime(VOTING_PERIOD);
        vm.stopPrank();
        console2.log("Proposal state after voting: ", uint256(myGovernor.state(proposalId)));

        // ! Queue TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        myGovernor.queue(targets, values, calldatas, descriptionHash);
        moveTime(MIN_DELAY);
        console2.log("Proposal state after queuing: ", uint256(myGovernor.state(proposalId)));

        // ! Execute
        myGovernor.execute(targets, values, calldatas, descriptionHash);
        console2.log("Proposal state after executing: ", uint256(myGovernor.state(proposalId)));

        assertEq(votingToken.balanceOf(USER_TO_ADD), AMOUNT_NEEDED);
    }

    function test_ChainlinkKeepersAndVRF() public {
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, 3 ether);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, address(funding));

        // ! Donate money
        sendMoneyToFundingContract();
        // ! Delegate tokens to voter
        enableVoterToCastVote(firstVoter, firstVoter);

        string memory description = "Description";
        bytes memory encodedFunctionCall =
            abi.encodeWithSignature("addNewUser(address,uint256)", USER_TO_ADD, AMOUNT_NEEDED);
        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(funding));

        // ! Propose to DAO
        uint256 proposalId = myGovernor.propose(targets, values, calldatas, description);
        console2.log("Proposal state when proposing: ", uint256(myGovernor.state(proposalId)));
        moveTime(VOTING_DELAY);
        console2.log("Proposal state after proposing: ", uint256(myGovernor.state(proposalId)));

        // ! Voting
        uint8 voteWay = 1;
        vm.startPrank(firstVoter);
        myGovernor.castVote(proposalId, voteWay);
        moveTime(VOTING_PERIOD);
        vm.stopPrank();
        console2.log("Proposal state after voting: ", uint256(myGovernor.state(proposalId)));

        // ! Queue TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        myGovernor.queue(targets, values, calldatas, descriptionHash);
        moveTime(MIN_DELAY);
        console2.log("Proposal state after queuing: ", uint256(myGovernor.state(proposalId)));

        // ! Execute
        myGovernor.execute(targets, values, calldatas, descriptionHash);
        console2.log("Proposal state after executing: ", uint256(myGovernor.state(proposalId)));

        // ! Request random number
        funding.performUpkeep("");
        // moveTime(interval);

        // ! Send random number to the funding contract and perform operations to send money to the "winner"
        vm.startPrank(vrfCoordinator);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = 1;
        funding.rawFulfillRandomWords(1, randomWords);
        vm.stopPrank();

        assertEq(funding.getRecentWinner(), USER_TO_ADD);
    }

    function test_funding_addNewUser_AddsNewUser() public {
        // ! Donate money
        sendMoneyToFundingContract();
        // ! Delegate tokens to voter
        enableVoterToCastVote(firstVoter, firstVoter);

        string memory description = "Description";
        bytes memory encodedFunctionCall =
            abi.encodeWithSignature("addNewUser(address,uint256)", USER_TO_ADD, AMOUNT_NEEDED);
        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(funding));

        // ! Propose to DAO
        uint256 proposalId = myGovernor.propose(targets, values, calldatas, description);
        console2.log("Proposal state when proposing: ", uint256(myGovernor.state(proposalId)));
        moveTime(VOTING_DELAY);
        console2.log("Proposal state after proposing: ", uint256(myGovernor.state(proposalId)));

        // ! Voting
        uint8 voteWay = 1;
        vm.startPrank(firstVoter);
        myGovernor.castVote(proposalId, voteWay);
        moveTime(VOTING_PERIOD);
        vm.stopPrank();
        console2.log("Proposal state after voting: ", uint256(myGovernor.state(proposalId)));

        // ! Queue TX
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        myGovernor.queue(targets, values, calldatas, descriptionHash);
        moveTime(MIN_DELAY);
        console2.log("Proposal state after queuing: ", uint256(myGovernor.state(proposalId)));

        // ! Execute
        myGovernor.execute(targets, values, calldatas, descriptionHash);
        console2.log("Proposal state after executing: ", uint256(myGovernor.state(proposalId)));

        assertEq(funding.getUserByIndex(0), USER_TO_ADD);
    }
}
