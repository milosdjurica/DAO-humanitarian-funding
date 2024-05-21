// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {VotingToken, Ownable} from "../../src/VotingToken.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {DeployAndSetUpContracts} from "../../script/DeployAndSetUpContracts.sol";

contract VotingTokenFuzzTests is Test {
    uint256 public constant TOKEN_AMOUNT_FIRST_MINT = 100 ether;

    VotingToken votingToken;
    TimeLock timeLock;

    address USER = makeAddr("USER");

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        (votingToken, timeLock,,,) = new DeployAndSetUpContracts().run();
    }

    function testFuzz_constructor_SetsOwner(address owner_) public {
        vm.assume(owner_ != address(0));
        vm.startPrank(owner_);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.owner(), owner_);
    }

    function testFuzz_constructor_MintsTokenForOwner(address owner_) public {
        vm.assume(owner_ != address(0));
        vm.startPrank(owner_);
        VotingToken testToken = new VotingToken();
        vm.stopPrank();
        assertEq(testToken.balanceOf(owner_), TOKEN_AMOUNT_FIRST_MINT);
    }

    function testFuzz_mint_RevertIf_CalledByNotOwner(address user_) public {
        vm.assume(user_ != address(timeLock));
        vm.startPrank(user_);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user_));
        votingToken.mint(user_, TOKEN_AMOUNT_FIRST_MINT);
        vm.stopPrank();
    }

    function testFuzz_mint_MintTokensSuccessfully(uint256 amount_) public {
        // ! In ERC20Votes -> maxSupply() == type(uint208).max
        vm.assume(amount_ <= type(uint208).max - TOKEN_AMOUNT_FIRST_MINT);
        vm.startPrank(address(timeLock));
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), USER, amount_);
        votingToken.mint(USER, amount_);
        vm.stopPrank();
        assertEq(votingToken.balanceOf(USER), amount_);
    }
}
