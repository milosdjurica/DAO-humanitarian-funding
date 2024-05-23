// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {VotingToken} from "../src/VotingToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Funding} from "../src/Funding.sol";
import {Constants} from "./Constants.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./CreateSubscription.s.sol";

contract DeployAndSetUpContracts is Script, Constants {
    Funding funding;
    MyGovernor myGovernor;
    TimeLock timeLock;
    VotingToken votingToken;

    address payable public USER = payable(makeAddr("user"));
    address[] public proposers;
    address[] public executors;
    address public firstVoter;

    function run() external returns (VotingToken, TimeLock, MyGovernor, Funding, address, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit,) =
            helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator);
        }

        vm.startBroadcast();
        votingToken = new VotingToken();
        firstVoter = votingToken.owner();

        timeLock = new TimeLock(MIN_DELAY, proposers, executors);
        myGovernor = new MyGovernor(
            GOVERNOR_NAME, VOTING_DELAY, VOTING_PERIOD, PROPOSAL_THRESHOLD, votingToken, QUORUM_PERCENTAGE, timeLock
        );

        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(myGovernor));
        timeLock.grantRole(executorRole, address(0)); // ! Everyone can execute
        timeLock.revokeRole(adminRole, address(this));

        funding = new Funding(interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        funding.transferOwnership(address(timeLock));
        votingToken.transferOwnership(address(timeLock));
        vm.stopBroadcast();

        return (votingToken, timeLock, myGovernor, funding, firstVoter, helperConfig);
    }
}
