// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ! Uncomment this line to use console.log
// import "hardhat/console.sol";

////////////////////
// * Imports 	  //
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
////////////////////

contract Funding is Ownable {
    ////////////////////
    // * Errors 	  //
    ////////////////////
    error Funding__ZeroAddress();
    error Funding__AmountIsZero();
    error Funding__NotEnoughBalance();
    error Funding__TransferFailed();

    ////////////////////
    // * Types 		  //
    ////////////////////

    ////////////////////
    // * Variables	  //
    ////////////////////
    address public s_winner;

    ////////////////////
    // * Events 	  //
    ////////////////////

    ////////////////////
    // * Modifiers 	  //
    ////////////////////

    ////////////////////
    // * Functions	  //
    ////////////////////

    ////////////////////
    // * Constructor  //
    ////////////////////
    constructor() Ownable(msg.sender) {}

    ////////////////////////////
    // * Receive & Fallback   //
    ////////////////////////////

    ////////////////////
    // * External 	  //
    ////////////////////

    ////////////////////
    // * Public 	  //
    ////////////////////
    function fund(address _userToFund, uint256 _amount) public onlyOwner {
        if (_userToFund == address(0)) revert Funding__ZeroAddress();
        if (_amount <= 0) revert Funding__AmountIsZero();
        if (address(this).balance <= _amount) revert Funding__NotEnoughBalance();

        s_winner = _userToFund;
        (bool success,) = _userToFund.call{value: _amount}("");
        if (!success) revert Funding__TransferFailed();
    }

    ////////////////////
    // * Internal 	  //
    ////////////////////

    ////////////////////
    // * Private 	  //
    ////////////////////

    ////////////////////
    // * View & Pure  //
    ////////////////////
}
