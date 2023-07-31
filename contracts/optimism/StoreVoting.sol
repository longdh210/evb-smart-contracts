//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// For cross domain messages' origin
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract StoreVoting {
    address[] public sender;
    uint256[] public partyId;
    uint256[] public proposal;

    event SetVotingData(
        address[] sender,
        uint256[] partyId,
        uint256[] proposal,
        address xorigin
    );

    function getSender() public view returns (address[] memory) {
        return sender;
    }

    function getParty() public view returns (uint256[] memory) {
        return partyId;
    }

    function getProposal() public view returns (uint256[] memory) {
        return proposal;
    }

    function setVotingData(
        address[] memory _sender,
        uint256[] memory _partyId,
        uint256[] memory _proposal
    ) public {
        sender = _sender;
        partyId = _partyId;
        proposal = _proposal;
        emit SetVotingData(_sender, _partyId, _proposal, getXorig());
    }

    // Get the cross domain origin, if any
    function getXorig() private view returns (address) {
        // Get the cross domain messenger's address each time.
        // This is less resource intensive than writing to storage.
        address cdmAddr = address(0);

        // Mainnet
        if (block.chainid == 1)
            cdmAddr = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;

        // Goerli
        if (block.chainid == 5)
            cdmAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

        // L2 (same address on every network)
        if (block.chainid == 10 || block.chainid == 420)
            cdmAddr = 0x4200000000000000000000000000000000000007;

        // If this isn't a cross domain message
        if (msg.sender != cdmAddr) return address(0);

        // If it is a cross domain message, find out where it is from
        return ICrossDomainMessenger(cdmAddr).xDomainMessageSender();
    } // getXorig()
}
