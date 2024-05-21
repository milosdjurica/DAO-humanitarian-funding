// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {VotingToken, Ownable, ERC20} from "../../src/VotingToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";

contract VotingTokenUnitTests is Test {
    uint256 public constant TOKEN_AMOUNT_FIRST_MINT = 100 ether;

    VotingToken votingToken;
    TimeLock timeLock;

    address USER = makeAddr("USER");
    address BOB = makeAddr("BOB");

    function setUp() public {
        (votingToken, timeLock,,,) = new DeployAndSetUpContracts().run();
    }

    function test_constructor_SetsOwner() public {
        vm.prank(USER);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.owner(), USER);
        assertEq(testToken.name(), "VotingToken");
        assertEq(testToken.symbol(), "VTK");
    }

    function test_constructor_MintsTokensOnInit() public {
        vm.prank(USER);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.balanceOf(USER), TOKEN_AMOUNT_FIRST_MINT);
    }

    function test_mint_RevertIf_CalledByNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        votingToken.mint(USER, TOKEN_AMOUNT_FIRST_MINT);
        vm.stopPrank();
    }

    function test_mint_MintsSuccessfully() public {
        vm.prank(address(timeLock));
        votingToken.mint(USER, TOKEN_AMOUNT_FIRST_MINT);
        assertEq(votingToken.balanceOf(USER), TOKEN_AMOUNT_FIRST_MINT);
    }
}
