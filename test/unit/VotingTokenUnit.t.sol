// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {VotingToken, Ownable} from "../../src/VotingToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";

contract VotingTokenUnitTests is Test {
    uint256 public constant TOKEN_AMOUNT_FIRST_MINT = 100 ether;

    VotingToken votingToken;
    TimeLock timeLock;

    address USER = makeAddr("USER");
    address BOB = makeAddr("BOB");
    address firstVoter;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        (votingToken, timeLock,,, firstVoter,) = new DeployAndSetUpContracts().run();
    }

    function test_constructor_InitsCorrectly() public {
        vm.startPrank(USER);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.owner(), USER);
        assertEq(testToken.name(), "VotingToken");
        assertEq(testToken.symbol(), "VTK");
    }

    function test_constructor_MintsTokensOnInit() public {
        vm.startPrank(USER);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.balanceOf(USER), TOKEN_AMOUNT_FIRST_MINT);
    }

    function test_mint_RevertIf_CalledByNotOwner() public {
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        votingToken.mint(USER, TOKEN_AMOUNT_FIRST_MINT);
        vm.stopPrank();
    }

    function test_mint_MintsSuccessfully() public {
        vm.startPrank(address(timeLock));
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), USER, TOKEN_AMOUNT_FIRST_MINT);
        votingToken.mint(USER, TOKEN_AMOUNT_FIRST_MINT);
        vm.stopPrank();
        assertEq(votingToken.balanceOf(USER), TOKEN_AMOUNT_FIRST_MINT);
    }

    function test_nonces_ReturnsZeroIfUserDoNotHaveVotingPower() public view {
        uint256 nonce = votingToken.nonces(USER);
        assertEq(nonce, 0);
    }
}
