// // SPDX-License-Identifier: GPL-3.0
// pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// contract BallotNew {
//     using EnumerableSet for EnumerableSet.AddressSet;
//     using Counters for Counters.Counter;

//     Counters.Counter private _partyCounter;

//     string public uri;

//     struct Voter {
//         uint256 weight; // weight is accumulated by delegation
//         bool voted; // if true, that person already voted
//         address delegate; // person delegated to
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
//         // string name;
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

//     /// Create a new ballot to choose one of `proposalNames`.
//     constructor(address superAdmin, string memory _uri) payable {
//         chairperson = superAdmin;
//         session = SESSION.PRIMARY_ELECTION;
//         lockContractTime = block.timestamp + (10 days);
//         uri = _uri;
//     }

//     function addParty(
//         string memory _uri,
//         string[] memory proposalUri
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
//         for (uint256 i = 0; i < proposalUri.length; i++) {
//             newParty.proposals.push(
//                 Proposal({proposalId: i, uri: proposalUri[i], voteCount: 0})
//             );
//         }
//         _partyCounter.increment();
//     }

//     // Give `voter` the right to vote on this party.
//     // May only be called by `chairperson`.
//     function giveRightToVote(
//         uint256 partyId,
//         address voter
//     ) external onlyChairperson {
//         if (session == SESSION.PRIMARY_ELECTION) {
//             require(
//                 msg.sender == chairperson,
//                 "Only chairperson can give right to vote."
//             );
//             require(
//                 !party[partyId].voterInfo[voter].voted,
//                 "The voter already voted."
//             );
//             require(party[partyId].voterInfo[voter].weight == 0);
//             party[partyId].listVoters.add(voter);
//             party[partyId].voterInfo[voter].weight = 1;
//         } else {
//             require(
//                 msg.sender == chairperson,
//                 "Only chairperson can give right to vote."
//             );
//             require(
//                 !votersForWinningSession[voter].voted,
//                 "The voter already voted."
//             );
//             require(votersForWinningSession[voter].weight == 0);
//             party[partyId].listVoters.add(voter);
//             votersForWinningSession[voter].weight = 1;
//         }
//     }

//     /// Delegate your vote to the voter `to`.
//     function delegate(uint256 partyId, address to) external {
//         if (session == SESSION.PRIMARY_ELECTION) {
//             // assigns reference
//             Voter storage sender = party[partyId].voterInfo[msg.sender];
//             require(sender.weight != 0, "You have no right to vote");
//             require(!sender.voted, "You already voted.");

//             require(to != msg.sender, "Self-delegation is disallowed.");

//             while (party[partyId].voterInfo[to].delegate != address(0)) {
//                 to = party[partyId].voterInfo[to].delegate;

//                 // We found a loop in the delegation, not allowed.
//                 require(to != msg.sender, "Found loop in delegation.");
//             }

//             Voter storage delegate_ = party[partyId].voterInfo[to];

//             // Voters cannot delegate to accounts that cannot vote.
//             require(delegate_.weight >= 1);

//             // Since `sender` is a reference, this
//             // modifies `voters[msg.sender]`.
//             sender.voted = true;
//             sender.delegate = to;

//             if (delegate_.voted) {
//                 // If the delegate already voted,
//                 // directly add to the number of votes
//                 party[partyId].proposals[delegate_.vote].voteCount += sender
//                     .weight;
//             } else {
//                 // If the delegate did not vote yet,
//                 // add to her weight.
//                 delegate_.weight += sender.weight;
//             }
//         } else {
//             Voter storage sender = votersForWinningSession[msg.sender];
//             require(sender.weight != 0, "You have no right to vote");
//             require(!sender.voted, "You already voted.");

//             require(to != msg.sender, "Self-delegation is disallowed.");

//             while (votersForWinningSession[to].delegate != address(0)) {
//                 to = votersForWinningSession[to].delegate;

//                 require(to != msg.sender, "Found loop in delegation.");
//             }

//             Voter storage delegate_ = votersForWinningSession[to];

//             require(delegate_.weight >= 1);

//             sender.voted = true;
//             sender.delegate = to;

//             if (delegate_.voted) {
//                 winningSession[delegate_.vote].voteCount += sender.weight;
//             } else {
//                 delegate_.weight += sender.weight;
//             }
//         }
//     }

//     /// Give your vote (including votes delegated to you)
//     /// to proposal `proposals[proposal].name`.
//     function vote(
//         address voter,
//         uint256 partyId,
//         uint256 proposal
//     ) external onlyChairperson {
//         if (session == SESSION.PRIMARY_ELECTION) {
//             Voter storage sender = party[partyId].voterInfo[voter];
//             require(sender.weight != 0, "Has no right to vote");
//             require(!sender.voted, "Already voted.");
//             sender.voted = true;
//             sender.vote = proposal;

//             // If `proposal` is out of the range of the array,
//             // this will throw automatically and revert all
//             // changes.
//             party[partyId].proposals[proposal].voteCount += sender.weight;
//         } else {
//             Voter storage sender = votersForWinningSession[voter];
//             require(sender.weight != 0, "Has no right to vote");
//             require(!sender.voted, "Already voted.");
//             sender.voted = true;
//             sender.vote = proposal;

//             winningSession[proposal].voteCount += sender.weight;
//         }
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
