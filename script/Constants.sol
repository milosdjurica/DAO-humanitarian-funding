// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract Constants {
    string public constant GOVERNOR_NAME = "MyGovernor";
    uint32 public constant VOTING_PERIOD = 50400; // ! Length of period during which people can cast their vote.
    uint48 public constant VOTING_DELAY = 7200; // ! Delay since proposal is created until voting starts.
    uint256 public constant PROPOSAL_THRESHOLD = 0; // ! Minimum number of votes an account must have to create a proposal.
    uint256 public constant QUORUM_PERCENTAGE = 4; // ! Quorum required for a proposal to pass.
    uint256 public constant MIN_DELAY = 3600; // ! 1 hour
}
