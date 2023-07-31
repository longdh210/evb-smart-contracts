// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./SmartAccount.sol";
import "hardhat/console.sol";

contract SmartAccountFactory {
    mapping(address => address) public accountOwners;
    mapping(address => bool) public isAccountCreated;
    address[] public deployedAccounts;

    event SmartAccountCreated(address indexed owner, address indexed account);

    function createSmartAccount(address _user, address _userOperation) public {
        require(
            !isAccountCreated[_user],
            "Account already created for this user"
        );

        SmartAccount newAccount = new SmartAccount(_user, _userOperation);
        accountOwners[_user] = address(newAccount);
        isAccountCreated[_user] = true;
        deployedAccounts.push(address(newAccount));
        console.log("run");
        emit SmartAccountCreated(_user, address(newAccount));
        console.log("run1");
    }

    function getDeployedAccounts() public view returns (address[] memory) {
        return deployedAccounts;
    }
}
