// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Ballot.sol";
import "hardhat/console.sol";

contract SmartAccount {
    address public owner;
    address public userOperation;

    constructor(address _owner, address _userOperation) {
        owner = _owner;
        userOperation = _userOperation;
    }

    function getMessageHashFromVote(
        address _to,
        uint256 partyId,
        uint256 proposal,
        string memory _message,
        uint _nonce
    ) public view returns (bytes32) {
        console.log("sender:", msg.sender);
        require(msg.sender == userOperation, "Only owner");
        return
            keccak256(
                abi.encodePacked(_to, partyId, proposal, _message, _nonce)
            );
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(
        address _signer,
        address _to,
        uint256 partyId,
        uint256 proposal,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHashFromVote(
            _to,
            partyId,
            proposal,
            _message,
            _nonce
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public view returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public view returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
}
