// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Invest is Ownable {
    uint256 public totalInvest;
    mapping(address => uint256) public fundedStartup;

    event Investment(address startup, uint256 value);

    function invest(address _startup, uint256 _value) public {
        (bool sent, bytes memory data) = _startup.call{value: _value}("");
        require(sent, "Failed to send Ether");
        totalInvest += _value;
        fundedStartup[_startup] = _value;
        emit Investment(_startup, _value);
    }
}
