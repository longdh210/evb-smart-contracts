// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IVoting {
    function giveRightToVote(uint256 partyId, address voter) external;

    function vote(address voter, uint256 partyId, uint256 proposal) external;
}
