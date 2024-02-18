solidity 
pragma solidity ^0.8.17;

contract DAO {
    struct Proposal {
        string desc;
        uint votecount;
        bool executed;
    }

    struct Member {
        address memberAddress;
        uint memberSince;
        uint tokenBalance;
    }

    address[] public members;
    mapping(address => Member) public memberInfo;
    mapping(address => mapping(uint => bool)) public votes;

    Proposal[] public proposal;
    uint public totalSupply;
    mapping(address => uint) public balances;

    event ProposalCreated(uint indexed proposalId, string desc);
    event VoteCast(address indexed voter, uint indexed proposalId, uint tokenAmount);
    event ProposalAccepted(string message);
    event ProposalRejected(string reject);

    function addMember(address _member) public {
        require(memberInfo[_member].memberAddress == address(0), "Member already exists");
        memberInfo[_member] = Member({memberAddress: _member, memberSince: block.timestamp, tokenBalance: 100});
        members.push(_member);
        balances[_member] = 100;
        totalSupply += 100;
    }

    function removeMember(address _member) public {
        require(memberInfo[_member].memberAddress != address(0), "Member does not exist");
        memberInfo[_member] = Member({memberAddress: address(0), memberSince: 0, tokenBalance: 0});
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
        balances[_member] = 0;
        totalSupply -= 100;
    }

    function createProposal(string memory _desc) public {
        proposal.push(Proposal({desc: _desc, votecount: 0, executed: false}));
        emit ProposalCreated(proposal.length - 1, _desc);
    }

    function vote(uint _proposalId, uint _tokenAmount) public {
        require(memberInfo[msg.sender].memberAddress != address(0), "Only members can vote");
        require(balances[msg.sender] >= _tokenAmount, "Not enough tokens to vote");
        require(votes[msg.sender][_proposalId] == false, "You have already voted for this proposal");
        votes[msg.sender][_proposalId] = true;
        memberInfo[msg.sender].tokenBalance -= _tokenAmount;
        proposal[_proposalId].votecount += _tokenAmount;
        emit VoteCast(msg.sender, _proposalId, _tokenAmount);
    }

    function executeProposal(uint _proposalId) public {
        require(proposal[_proposalId].executed == false, "Proposal has already been executed");
        if ((proposal[_proposalId].votecount * 100 / totalSupply) >= 50) {
            proposal[_proposalId].executed = true;
            emit ProposalAccepted("Proposal has been approved");
        } else {
            emit ProposalRejected("Proposal has not been approved by majority vote");
        }
    }
}