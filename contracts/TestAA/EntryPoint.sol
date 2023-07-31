// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserOperation.sol";
import "./SmartAccountFactory.sol";

contract EntryPoint {
    UserOperation public userOperation;
    SmartAccountFactory public smartAccountFactory;

    constructor(
        UserOperation _userOperation,
        SmartAccountFactory _smartAccountFactory
    ) {
        userOperation = _userOperation;
        smartAccountFactory = _smartAccountFactory;
    }

    function handleVoteRequest(
        address _smartAccountAddress,
        address _to,
        uint256 _partyId,
        uint256 _proposal,
        string memory _message,
        uint _nonce
    ) public view returns (bytes32) {
        return
            userOperation.getMessageHashFromVote(
                _smartAccountAddress,
                _to,
                _partyId,
                _proposal,
                _message,
                _nonce
            );
    }

    function handleVerifySign(
        address _smartAccountAddress,
        address _signer,
        address _to,
        uint256 partyId,
        uint256 proposal,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public view returns (bool) {
        return
            userOperation.verifySignature(
                _smartAccountAddress,
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
