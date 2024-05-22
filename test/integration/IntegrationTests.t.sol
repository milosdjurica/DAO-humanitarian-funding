// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {VotingToken} from "../../src/VotingToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {Constants} from "../../script/Constants.sol";

contract IntegrationTests is Test, Constants {
    uint256 public constant AMOUNT_NEEDED = 1 ether;
    uint256 public constant SENDER_FUNDS = 100 ether;

    VotingToken votingToken;
    TimeLock timeLock;
    MyGovernor myGovernor;
    Funding funding;
    DeployAndSetUpContracts deployer;

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
        (votingToken, timeLock, myGovernor, funding, firstVoter) = deployer.run();
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

    // TODO -> test_addUser !!! This is only function that owner can call
    // TODO -> add integration tests for chainlink keepers and VRF
    function test_fund_SuccessfullyFunded() public {
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

        assert(funding.getUserByIndex(0) == USER_TO_ADD);
    }
}
