// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding} from "../src/Funding.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {VotingToken} from "../src/VotingToken.sol";

contract ExampleTest is Test {
    Funding funding;
    MyGovernor myGovernor;
    TimeLock timeLock;
    VotingToken votingToken;

    string public constant GOVERNOR_NAME = "MyGovernor";
    uint32 public constant VOTING_PERIOD = 50400; // ! Length of period during which people can cast their vote.
    uint48 public constant VOTING_DELAY = 7200; // ! Delay since proposal is created until voting starts.
    uint256 public constant PROPOSAL_THRESHOLD = 0; // ! Minimum number of votes an account must have to create a proposal.
    uint256 public constant QUORUM_PERCENTAGE = 4; // ! Quorum required for a proposal to pass.
    uint256 public constant AMOUNT_TO_MINT = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // ! hour

    address public USER = makeAddr("user");
    address[] public proposers;
    address[] public executors;

    function setUp() public {
        votingToken = new VotingToken();
        votingToken.mint(USER, AMOUNT_TO_MINT);

        vm.startPrank(USER);
        votingToken.delegate(USER);
        timeLock = new TimeLock(MIN_DELAY, proposers, executors);
        myGovernor = new MyGovernor(
            GOVERNOR_NAME, VOTING_DELAY, VOTING_PERIOD, PROPOSAL_THRESHOLD, votingToken, QUORUM_PERCENTAGE, timeLock
        );

        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(myGovernor));
        timeLock.grantRole(executorRole, address(0)); // ! Everyone can execute
        timeLock.revokeRole(adminRole, USER);

        vm.stopPrank();
    }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
