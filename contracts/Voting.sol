// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Ballot {
    struct Voter {
        uint256 weight; // weight is accumulated by delegation
        bool voted; // if true, that person already voted
        address delegate; // person delegated to
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
        mapping(address => Voter) voters;
    }

    Party[] party;

    uint256 public partyCount;

    enum SESSION {
        PRIMARY_ELECTION,
        GENERAL_ELECTION
    }

    SESSION private session;

    Proposal[] public winningSession;
    mapping(address => Voter) votersForWinningSession;

    uint256 public lockContract;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor() payable {
        chairperson = msg.sender;
        partyCount = 0;
        session = SESSION.PRIMARY_ELECTION;
        lockContract = block.timestamp + (10 days);
    }

    function addToParty(string memory partyName, string[] memory proposalNames)
        public
        payable
        onlyChairperson
    {
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
        for (uint256 i = 0; i < proposalNames.length; i++) {
            newParty.proposals.push(
                Proposal({name: proposalNames[i], voteCount: 0})
            );
        }
        partyCount++;
    }

    // Give `voter` the right to vote on this party.
    // May only be called by `chairperson`.
    function giveRightToVote(uint256 partyId, address voter) external {
        if (session == SESSION.PRIMARY_ELECTION) {
            require(
                msg.sender == chairperson,
                "Only chairperson can give right to vote."
            );
            require(
                !party[partyId].voters[voter].voted,
                "The voter already voted."
            );
            require(party[partyId].voters[voter].weight == 0);
            party[partyId].voters[voter].weight = 1;
        } else {
            require(
                msg.sender == chairperson,
                "Only chairperson can give right to vote."
            );
            require(
                !votersForWinningSession[voter].voted,
                "The voter already voted."
            );
            require(votersForWinningSession[voter].weight == 0);
            votersForWinningSession[voter].weight = 1;
        }
    }

    /// Delegate your vote to the voter `to`.
    function delegate(uint256 partyId, address to) external {
        if (session == SESSION.PRIMARY_ELECTION) {
            // assigns reference
            Voter storage sender = party[partyId].voters[msg.sender];
            require(sender.weight != 0, "You have no right to vote");
            require(!sender.voted, "You already voted.");

            require(to != msg.sender, "Self-delegation is disallowed.");

            while (party[partyId].voters[to].delegate != address(0)) {
                to = party[partyId].voters[to].delegate;

                // We found a loop in the delegation, not allowed.
                require(to != msg.sender, "Found loop in delegation.");
            }

            Voter storage delegate_ = party[partyId].voters[to];

            // Voters cannot delegate to accounts that cannot vote.
            require(delegate_.weight >= 1);

            // Since `sender` is a reference, this
            // modifies `voters[msg.sender]`.
            sender.voted = true;
            sender.delegate = to;

            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                party[partyId].proposals[delegate_.vote].voteCount += sender
                    .weight;
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight += sender.weight;
            }
        } else {
            Voter storage sender = votersForWinningSession[msg.sender];
            require(sender.weight != 0, "You have no right to vote");
            require(!sender.voted, "You already voted.");

            require(to != msg.sender, "Self-delegation is disallowed.");

            while (votersForWinningSession[to].delegate != address(0)) {
                to = votersForWinningSession[to].delegate;

                require(to != msg.sender, "Found loop in delegation.");
            }

            Voter storage delegate_ = votersForWinningSession[to];

            require(delegate_.weight >= 1);

            sender.voted = true;
            sender.delegate = to;

            if (delegate_.voted) {
                winningSession[delegate_.vote].voteCount += sender.weight;
            } else {
                delegate_.weight += sender.weight;
            }
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint256 partyId, uint256 proposal) external {
        if (session == SESSION.PRIMARY_ELECTION) {
            Voter storage sender = party[partyId].voters[msg.sender];
            require(sender.weight != 0, "Has no right to vote");
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;

            // If `proposal` is out of the range of the array,
            // this will throw automatically and revert all
            // changes.
            party[partyId].proposals[proposal].voteCount += sender.weight;
        } else {
            Voter storage sender = votersForWinningSession[msg.sender];
            require(sender.weight != 0, "Has no right to vote");
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;

            winningSession[proposal].voteCount += sender.weight;
        }
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal(uint256 partyId)
        public
        view
        returns (uint256 winningProposal_)
    {
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

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "You are not chairperson");
        _;
    }
}
