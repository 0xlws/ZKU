// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;  
        address delegate; 
        uint vote;   
    }

    struct Proposal {
        bytes32 name; 
        uint voteCount; 
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Instead of entering 10 voters in 10 seperate calls,
    // enter an array of 10 addresses in 1 call
    function giveRightToVote(address[10] memory voter) public {
        // keep the same constraints
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
            );
        // Loop trough the array of voters then check if conditions are met
        for (uint i=0; i<voter.length; i++){
            require(
                !voters[voter[i]].voted,
                "The voter already voted."
                );
            require(voters[voter[i]].weight == 0);
            voters[voter[i]].weight = 1;
        }
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}