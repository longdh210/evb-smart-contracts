//SPDX-License-Identifier: Unlicense
// This contracts runs on L2, and controls a Greeter on L1.
// The greeter address is specific to Goerli.
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract FromL2_ControlL1 {
    address crossDomainMessengerAddr =
        0x4200000000000000000000000000000000000007;

    address storeVotingL1Addr = 0x4d0fcc1Bedd933dA4121240C2955c3Ceb68AAE84;

    function setSubmit(
        address[] calldata _sender,
        uint256[] calldata _partyId,
        uint256[] calldata _proposal
    ) public {
        bytes memory message;

        message = abi.encodeWithSignature(
            "setVotingData(address[],uint256[],uint256[])",
            _sender,
            _partyId,
            _proposal
        );

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            storeVotingL1Addr,
            message,
            1000000 // irrelevant here
        );
    } // function setGreeting

    address[] public senderS1;
    uint256[] public partyIdS1;
    uint256[] public proposalS1;

    function getSenderS1() public view returns (address[] memory) {
        return senderS1;
    }

    function getPartyS1() public view returns (uint256[] memory) {
        return partyIdS1;
    }

    function getProposalS1() public view returns (uint256[] memory) {
        return proposalS1;
    }

    address[] public senderS2;
    uint256[] public partyIdS2;
    uint256[] public proposalS2;

    function getSenderS2() public view returns (address[] memory) {
        return senderS2;
    }

    function getPartyS2() public view returns (uint256[] memory) {
        return partyIdS2;
    }

    function getProposalS2() public view returns (uint256[] memory) {
        return proposalS2;
    }

    struct Voter {
        bool voted; // if true, that person already voted
        uint256 vote; // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        string name; // short name (up to 32 bytes)
        uint256 voteCount; // number of accumulated votes
    }

    address public chairperson;

    struct Party {
        string name;
        Proposal[] proposals;
        bytes32 root;
        mapping(address => Voter) voters;
    }

    Party[] public party;

    uint256 public partyCount;

    enum SESSION {
        PRIMARY_ELECTION,
        GENERAL_ELECTION
    }

    SESSION private session;

    Proposal[] public winningSession;
    mapping(address => Voter) votersForWinningSession;

    uint256 public lockContract;

    event Voted(
        address indexed voter,
        uint256 indexed partyId,
        uint256 indexed proposal
    );

    /// Create a new ballot to choose one of `proposalNames`.
    constructor() payable {
        chairperson = msg.sender;
        partyCount = 0;
        session = SESSION.PRIMARY_ELECTION;
        lockContract = block.timestamp + (10 days);
    }

    function addToParty(
        string memory partyName,
        string[] memory proposalNames,
        bytes32 _root
    ) public payable onlyChairperson {
        require(
            block.timestamp <= lockContract,
            "Time up, can not add to party"
        );
        require(
            session == SESSION.PRIMARY_ELECTION,
            "Can not add party in COUNTRY_VOTE session"
        );
        Party storage newParty = party.push();
        newParty.name = partyName;
        newParty.root = _root;
        for (uint256 i = 0; i < proposalNames.length; i++) {
            newParty.proposals.push(
                Proposal({name: proposalNames[i], voteCount: 0})
            );
        }
        partyCount++;
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(
        uint256 partyId,
        uint256 proposal,
        bytes32[] calldata _merkleProof
    ) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, party[partyId].root, leaf),
            "User is not in whitelist"
        );
        if (session == SESSION.PRIMARY_ELECTION) {
            Voter storage sender = party[partyId].voters[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;

            // If `proposal` is out of the range of the array,
            // this will throw automatically and revert all
            // changes.
            party[partyId].proposals[proposal].voteCount += 1;
            senderS1.push(msg.sender);
            partyIdS1.push(partyId);
            proposalS1.push(proposal);
        } else {
            Voter storage sender = votersForWinningSession[msg.sender];
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;

            winningSession[proposal].voteCount += 1;
            senderS2.push(msg.sender);
            partyIdS2.push(partyId);
            proposalS2.push(proposal);
        }
        emit Voted(msg.sender, partyId, proposal);
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal(
        uint256 partyId
    ) public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < party[partyId].proposals.length; p++) {
            if (party[partyId].proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = party[partyId].proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // // Calls winningProposal() function to get the index
    // // of the winner contained in the proposals array and then
    // // returns the name of the winner
    function winnerPrimary() public {
        require(
            session == SESSION.PRIMARY_ELECTION,
            "Not in primary election progress"
        );
        require(lockContract < block.timestamp, "Voting in progress");
        for (uint256 i = 0; i < party.length; i++) {
            string memory winnerName = party[i]
                .proposals[winningProposal(i)]
                .name;
            winningSession.push(Proposal({name: winnerName, voteCount: 0}));
        }
        session = SESSION.GENERAL_ELECTION;
        // lockContract = block.timestamp + (5 days);
    }

    function winningProposalGeneral()
        public
        view
        returns (uint256 winningProposal_)
    {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < winningSession.length; p++) {
            if (winningSession[p].voteCount > winningVoteCount) {
                winningVoteCount = winningSession[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerGeneral() external view returns (string memory winnerName_) {
        require(
            session == SESSION.GENERAL_ELECTION,
            "Not in general election progress"
        );
        require(lockContract < block.timestamp, "Voting in progress");
        winnerName_ = winningSession[winningProposalGeneral()].name;
    }

    // function getParties() public view returns (Party[] memory) {
    //     return party;
    // }

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "You are not chairperson");
        _;
    }
} // contract FromL2_ControlL1Greeter
