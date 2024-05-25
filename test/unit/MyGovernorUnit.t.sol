// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.s.sol";
import {Constants} from "../../script/Constants.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";
import {VotingToken} from "../../src/VotingToken.sol";

contract MyGovernorUnitTests is Test, Constants {
    DeployAndSetUpContracts deployer;
    TimeLock timeLock;
    MyGovernor myGovernor;
    VotingToken votingToken;

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (votingToken, timeLock, myGovernor,,,) = deployer.run();
    }

    function test_constructor_Name() public view {
        assertEq(myGovernor.name(), GOVERNOR_NAME);
    }

    function test_timelock() public view {
        assertEq(myGovernor.timelock(), address(timeLock));
    }

    function test_votingDelay() public view {
        assertEq(myGovernor.votingDelay(), VOTING_DELAY);
    }

    function test_votingPeriod() public view {
        assertEq(myGovernor.votingPeriod(), VOTING_PERIOD);
    }

    function test_proposalThreshold() public view {
        assertEq(myGovernor.proposalThreshold(), PROPOSAL_THRESHOLD);
    }

    function test_token() public view {
        assertEq(address(myGovernor.token()), address(votingToken));
    }
}
