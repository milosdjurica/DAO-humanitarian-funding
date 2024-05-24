// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    HelperConfig helperConfig;

    function setUp() public {
        helperConfig = new HelperConfig();
    }

    function test_getSepoliaEthConfig() public {
        vm.chainId(11155111);
        HelperConfig helperConfigSepolia = new HelperConfig();
        (uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint64 callbackGasLimit) =
            helperConfigSepolia.activeNetworkConfig();

        assertEq(interval, 30);
        assertEq(vrfCoordinator, 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
        assertEq(gasLane, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c);
        assertEq(subscriptionId, 7694);
        assertEq(callbackGasLimit, 500000);
    }

    function test_getOrCreateAnvilConfig() public view {
        (uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint64 callbackGasLimit) =
            helperConfig.activeNetworkConfig();

        assertEq(interval, 30);

        assertEq(vrfCoordinator != address(0), true);
        assertEq(gasLane, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c);
        assertEq(subscriptionId, 1);
        assertEq(callbackGasLimit, 500000);
    }

    function test_activeNetworkConfig() public view {
        (uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint64 callbackGasLimit) =
            helperConfig.activeNetworkConfig();

        if (block.chainid == 11155111) {
            assertEq(interval, 30);
            assertEq(vrfCoordinator, address(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625));
            assertEq(gasLane, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c);
            assertEq(subscriptionId, 7694);
            assertEq(callbackGasLimit, 500000);
        } else {
            assertEq(interval, 30);
            assertEq(vrfCoordinator != address(0), true);
            assertEq(gasLane, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c);
            assertEq(subscriptionId, 1);
            assertEq(callbackGasLimit, 500000);
        }
    }
}
