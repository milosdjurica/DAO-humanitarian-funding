// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    uint96 constant BASE_FEE_VRF_MOCK = 0.25 ether; // 0.25 LINK
    uint96 constant GAS_PRICE_LINK_VRF_MOCK = 1e9; // 1 gwei LINK

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // TODO create networkConfig for Mainnet
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            interval: 30, // 30 secs
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, // TODO -> change this to your subscription !!!
            callbackGasLimit: 500000 // 500,000 gas !
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) return activeNetworkConfig;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(BASE_FEE_VRF_MOCK, GAS_PRICE_LINK_VRF_MOCK);
        vm.stopBroadcast();

        return NetworkConfig({
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // does not matter
            subscriptionId: 0, // our script will add this
            callbackGasLimit: 5000
        });
    }
}
