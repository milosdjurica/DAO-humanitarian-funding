// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();

        (, address vrfCoordinator,, uint64 subId,, address linkToken) = helperConfig.activeNetworkConfig();

        fundSubscription(vrfCoordinator, subId, linkToken);
    }

    function fundSubscription(address vrfCoordinator, uint64 subId, address linkToken) public {
        console2.log("Funding subscription with ID -> ", subId);
        console2.log("Using VRF Coordinator -> ", vrfCoordinator);
        console2.log("Link token addr -> ", linkToken);
        console2.log("On Chain ID -> ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
