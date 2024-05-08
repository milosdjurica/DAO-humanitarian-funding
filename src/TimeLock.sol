// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    constructor(uint256 _minDelay, address[] memory _proposers, address[] memory _executors)
        TimelockController(_minDelay, _proposers, _executors, msg.sender)
    {}
}
