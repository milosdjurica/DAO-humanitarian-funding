// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RevertTransfer {
    error RevertTransfer__ContractDoesNotAcceptEther();

    receive() external payable {
        revert RevertTransfer__ContractDoesNotAcceptEther();
    }
}
