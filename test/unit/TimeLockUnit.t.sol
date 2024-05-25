// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";
import {Constants} from "../../script/Constants.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";

contract TimeLockUnitTests is Test, Constants {
    DeployAndSetUpContracts deployer;
    TimeLock timeLock;
    MyGovernor myGovernor;

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (, timeLock, myGovernor,,,) = deployer.run();
    }

    function test_constructor_InitsCorrectly() public view {
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();

        assertEq(timeLock.getMinDelay(), MIN_DELAY);
        assertTrue(timeLock.hasRole(proposerRole, address(myGovernor)));
        assertTrue(timeLock.hasRole(executorRole, address(0)));
        // TODO -> Test admin role ???
    }
}
