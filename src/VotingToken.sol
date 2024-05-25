// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VotingToken
 * @dev A contract for a voting token that extends ERC20 functionality and includes voting capabilities
 */
contract VotingToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    /**
     * @notice The owner of this contract is initially the deployer, but ownership is transferred to a TimeLock contract in the deployment script. That way only DAO can control who can mint tokens (who joins the DAO).
     * @notice Deployer of this contract is the first participant (voter) of the DAO
     */
    constructor() ERC20("VotingToken", "VTK") ERC20Permit("VotingToken") Ownable(msg.sender) {
        mint(msg.sender, 100 ether);
    }

    /**
     * @dev Mints new voting tokens and assigns them to the specified address
     * @param to The address to which the new tokens will be minted
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // The functions below are overrides required by Solidity.

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
