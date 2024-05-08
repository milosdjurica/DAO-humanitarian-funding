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

    function setUp() public {
        votingToken = new VotingToken();
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
