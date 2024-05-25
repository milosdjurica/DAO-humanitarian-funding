// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VotingToken} from "../src/VotingToken.sol";

contract DeployVotingTokenScript is Script {
    function run() public returns (VotingToken) {
        vm.startBroadcast();
        VotingToken votingToken = new VotingToken();
        vm.stopBroadcast();
        return votingToken;
    }
}
