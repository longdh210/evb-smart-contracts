// // SPDX-License-Identifier: GPL-3.0
// pragma solidity ^0.8.4;

// import "./BallotRootNew.sol";

// contract DeployBallot {
//     address public superAdmin;

//     event NewBallotDeployed(address indexed ballotRoot);

//     constructor(address _superAdmin) {
//         require(
//             _superAdmin != address(0) && _superAdmin != address(this),
//             "superAdmin"
//         );
//         superAdmin = _superAdmin;
//     }

//     function createBallot(address chairperson, string memory _uri) public {
//         require(msg.sender == superAdmin, "Only super admin");
//         // BallotRootNew newBallot = new BallotRootNew(chairperson, _uri);

//         emit NewBallotDeployed(address(newBallot));
//     }
// }
