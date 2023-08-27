// // SPDX-License-Identifier: GPL-3.0
// pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// contract BallotRootNew {
//     using EnumerableSet for EnumerableSet.AddressSet;
//     using Counters for Counters.Counter;

//     Counters.Counter private _partyCounter;

//     string public uri;

//     struct Voter {
//         bool voted; // if true, that person already voted
//         uint256 vote; // index of the voted proposal
//     }

//     // This is a type for a single proposal.
//     struct Proposal {
//         uint256 proposalId;
//         string uri;
//         uint256 voteCount; // number of accumulated votes
//     }

//     address public chairperson;

//     struct Party {
//         uint256 partyId;
//         string uri;
//         bytes32 root;
//         Proposal[] proposals;
//         EnumerableSet.AddressSet listVoters;
//         mapping(address => Voter) voterInfo;
//     }

//     Party[] private party;

//     enum SESSION {
//         PRIMARY_ELECTION,
//         GENERAL_ELECTION
//     }

//     SESSION private session;

//     Proposal[] public winningSession;
//     mapping(address => Voter) votersForWinningSession;

//     uint256 public lockContractTime;

//     event Voted(
//         address indexed voter,
//         uint256 indexed partyId,
//         uint256 indexed proposal
//     );

//     /// Create a new ballot to choose one of `proposalNames`.
//     constructor(address superAdmin, string memory _uri) payable {
//         chairperson = superAdmin;
//         session = SESSION.PRIMARY_ELECTION;
//         lockContractTime = block.timestamp + (10 days);
//         uri = _uri;
//     }

//     function addParty(
//         string memory _uri,
//         string[] memory proposalUri,
//         bytes32 _root
//     ) public payable onlyChairperson {
//         require(
//             block.timestamp <= lockContractTime,
//             "Time up, can not add to party"
//         );
//         require(
//             session == SESSION.PRIMARY_ELECTION,
//             "Can not add party in COUNTRY_VOTE session"
//         );
//         Party storage newParty = party.push();
//         newParty.partyId = _partyCounter.current();
//         newParty.uri = _uri;
//         newParty.root = _root;
//         for (uint256 i = 0; i < proposalUri.length; i++) {
//             newParty.proposals.push(
//                 Proposal({proposalId: i, uri: proposalUri[i], voteCount: 0})
//             );
//         }
//         _partyCounter.increment();
//     }

//     /// Give your vote (including votes delegated to you)
//     /// to proposal `proposals[proposal].name`.
//     function vote(
//         uint256 partyId,
//         uint256 proposal,
//         address inputVoter,
//         bytes32[] calldata _merkleProof
//     ) external onlyChairperson {
//         bytes32 leaf = keccak256(abi.encodePacked(inputVoter));
//         require(
//             MerkleProof.verify(_merkleProof, party[partyId].root, leaf),
//             "User is not in whitelist"
//         );
//         if (session == SESSION.PRIMARY_ELECTION) {
//             Voter storage sender = party[partyId].voterInfo[inputVoter];
//             require(!sender.voted, "Already voted.");
//             sender.voted = true;
//             sender.vote = proposal;

//             // If `proposal` is out of the range of the array,
//             // this will throw automatically and revert all
//             // changes.
//             party[partyId].proposals[proposal].voteCount += 1;
//         } else {
//             Voter storage sender = votersForWinningSession[inputVoter];
//             require(!sender.voted, "Already voted.");
//             sender.voted = true;
//             sender.vote = proposal;

//             winningSession[proposal].voteCount += 1;
//         }
//         emit Voted(msg.sender, partyId, proposal);
//     }

//     /// @dev Computes the winning proposal taking all
//     /// previous votes into account.
//     function winningProposal(
//         uint256 partyId
//     ) public view returns (uint256 winningProposal_) {
//         uint256 winningVoteCount = 0;
//         for (uint256 p = 0; p < party[partyId].proposals.length; p++) {
//             if (party[partyId].proposals[p].voteCount > winningVoteCount) {
//                 winningVoteCount = party[partyId].proposals[p].voteCount;
//                 winningProposal_ = p;
//             }
//         }
//     }

//     // // Calls winningProposal() function to get the index
//     // // of the winner contained in the proposals array and then
//     // // returns the name of the winner
//     function winnerPrimary() public {
//         require(
//             session == SESSION.PRIMARY_ELECTION,
//             "Not in primary election progress"
//         );
//         require(lockContractTime < block.timestamp, "Voting in progress");
//         for (uint256 i = 0; i < party.length; i++) {
//             uint256 winnerId = party[i]
//                 .proposals[winningProposal(i)]
//                 .proposalId;
//             string memory winnerUri = party[i]
//                 .proposals[winningProposal(i)]
//                 .uri;
//             winningSession.push(
//                 Proposal({proposalId: winnerId, uri: winnerUri, voteCount: 0})
//             );
//         }
//         session = SESSION.GENERAL_ELECTION;
//         // lockContractTime = block.timestamp + (5 days);
//     }

//     function winningProposalGeneral()
//         public
//         view
//         returns (uint256 winningProposal_)
//     {
//         uint256 winningVoteCount = 0;
//         for (uint256 p = 0; p < winningSession.length; p++) {
//             if (winningSession[p].voteCount > winningVoteCount) {
//                 winningVoteCount = winningSession[p].voteCount;
//                 winningProposal_ = p;
//             }
//         }
//     }

//     function winnerGeneral() external view returns (uint256 winnerId_) {
//         require(
//             session == SESSION.GENERAL_ELECTION,
//             "Not in general election progress"
//         );
//         require(lockContractTime < block.timestamp, "Voting in progress");
//         winnerId_ = winningSession[winningProposalGeneral()].proposalId;
//     }

//     function getPartyById(uint256 partyId) public view returns (string memory) {
//         return party[partyId].uri;
//     }

//     function getAllParty() public view returns (string[] memory) {
//         string[] memory listParty = new string[](_partyCounter.current());
//         for (uint i = 0; i < _partyCounter.current(); i++) {
//             listParty[i] = party[i].uri;
//         }
//         return listParty;
//     }

//     function getAllVoters(
//         uint256 partyId
//     ) public view returns (address[] memory) {
//         return party[partyId].listVoters.values();
//     }

//     function getVoterInfo(
//         uint256 partyId,
//         address voter
//     ) public view returns (Voter memory) {
//         return party[partyId].voterInfo[voter];
//     }

//     function getProposalsInfo(
//         uint256 partyId
//     ) public view returns (Proposal[] memory) {
//         return party[partyId].proposals;
//     }

//     modifier onlyChairperson() {
//         require(msg.sender == chairperson, "You are not chairperson");
//         _;
//     }
// }
