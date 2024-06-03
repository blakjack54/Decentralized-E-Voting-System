// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EVoting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Election {
        string name;
        uint256 startTime;
        uint256 endTime;
        bool concluded;
        mapping(address => bool) voters;
        Candidate[] candidates;
    }

    uint256 public electionCount;
    mapping(uint256 => Election) public elections;

    event ElectionCreated(uint256 electionId, string name, uint256 startTime, uint256 endTime);
    event Voted(uint256 electionId, address voter, uint256 candidateId);
    event ElectionConcluded(uint256 electionId);

    function createElection(string memory name, uint256 duration, string[] memory candidateNames) external {
        electionCount++;
        Election storage election = elections[electionCount];
        election.name = name;
        election.startTime = block.timestamp;
        election.endTime = block.timestamp + duration;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            election.candidates.push(Candidate(candidateNames[i], 0));
        }
        emit ElectionCreated(electionCount, name, election.startTime, election.endTime);
    }

    function vote(uint256 electionId, uint256 candidateId) external {
        Election storage election = elections[electionId];
        require(block.timestamp >= election.startTime, "Election not started");
        require(block.timestamp <= election.endTime, "Election ended");
        require(!election.voters[msg.sender], "Already voted");
        require(candidateId < election.candidates.length, "Invalid candidate");

        election.voters[msg.sender] = true;
        election.candidates[candidateId].voteCount++;
        emit Voted(electionId, msg.sender, candidateId);
    }

    function concludeElection(uint256 electionId) external {
        Election storage election = elections[electionId];
        require(block.timestamp > election.endTime, "Election not ended");
        require(!election.concluded, "Election already concluded");

        election.concluded = true;
        emit ElectionConcluded(electionId);
    }

    function getCandidate(uint256 electionId, uint256 candidateId) external view returns (string memory name, uint256 voteCount) {
        Election storage election = elections[electionId];
        Candidate storage candidate = election.candidates[candidateId];
        return (candidate.name, candidate.voteCount);
    }
}
