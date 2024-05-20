// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Funding, Ownable} from "../../src/Funding.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";

contract FundingUnitTests is Test {
    uint256 public constant AMOUNT_TO_FUND = 1 ether;
    uint256 public constant SENDER_FUNDS = 100 ether;

    Funding funding;
    DeployAndSetUpContracts deployer;

    address payable public USER = payable(makeAddr("USER"));
    address payable public SENDER = payable(makeAddr("SENDER"));
    address public USER_TO_GET_FUNDED = makeAddr("USER_TO_GET_FUNDED");

    function setUp() public {
        deployer = new DeployAndSetUpContracts();
        (,,, funding,) = deployer.run();
    }
}
