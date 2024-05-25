// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title TimeLock
 * @dev This contract implements a time-lock mechanism using OpenZeppelin's TimelockController.
 * It acts as the owner of the Funding and VotingToken contracts and executes proposals passed to it by the MyGovernor contract.
 * @dev Read more on -> https://docs.openzeppelin.com/contracts/5.x/governance
 */
contract TimeLock is TimelockController {
    constructor(uint256 _minDelay, address[] memory _proposers, address[] memory _executors)
        TimelockController(_minDelay, _proposers, _executors, msg.sender)
    {}
}
