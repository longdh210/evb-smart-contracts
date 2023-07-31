// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SmartAccount.sol";

contract UserOperation {
    function getMessageHashFromVote(
        address smartAccountAddress,
        address _to,
        uint256 _partyId,
        uint256 _proposal,
        string memory _message,
        uint _nonce
    ) public view returns (bytes32) {
        SmartAccount smartAccount = SmartAccount(smartAccountAddress);
        return
            smartAccount.getMessageHashFromVote(
                _to,
                _partyId,
                _proposal,
                _message,
                _nonce
            );
    }

    function verifySignature(
        address smartAccountAddress,
        address _signer,
        address _to,
        uint256 partyId,
        uint256 proposal,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public view returns (bool) {
        SmartAccount smartAccount = SmartAccount(smartAccountAddress);
        return
            smartAccount.verify(
                _signer,
                _to,
                partyId,
                proposal,
                _message,
                _nonce,
                signature
            );
    }
}
