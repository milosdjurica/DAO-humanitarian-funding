// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ! Uncomment this line to use console.log
// import "hardhat/console.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Funding is Ownable {
    error Funding__ZeroAddress();
    error Funding__AmountIsZero();
    error Funding__NotEnoughBalance(uint256 balance);
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
    event AmountFunded(uint256 indexed amount);
    event MoneyIsSentToUser(address indexed userToFund, uint256 indexed amount);

    ////////////////////
    // * Modifiers 	  //
    ////////////////////

    constructor() Ownable(msg.sender) {}

    fallback() external payable {
        emit AmountFunded(msg.value);
    }

    receive() external payable {
        emit AmountFunded(msg.value);
    }

    function fund(address _userToFund, uint256 _amount) public onlyOwner {
        if (_userToFund == address(0)) revert Funding__ZeroAddress();
        if (_amount <= 0) revert Funding__AmountIsZero();
        if (address(this).balance <= _amount) revert Funding__NotEnoughBalance(address(this).balance);

        s_winner = _userToFund;
        emit MoneyIsSentToUser(_userToFund, _amount);
        (bool success,) = _userToFund.call{value: _amount}("");
        if (!success) revert Funding__TransferFailed();
    }
}
