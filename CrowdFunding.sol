// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding
{

    mapping(address=>uint256) public contributors;
    address public manager;
    uint public minAmountOfContribution;
    uint public deadlineTime;
    uint public targetAmount;
    uint public raisedAmount;
    uint public NoOfContributors;

    struct Request
    {
        string description;
        uint value;
        bool completed;
        uint noOfVoters;
        address payable recipient;
        mapping(address=>bool) voters;
    }
    mapping (uint=>Request) public requests;
    uint public numRequests;
    constructor (uint _targetAmount,  uint _deadlineTime, uint _minAmountOfContribution) {
        manager = msg.sender;
        minAmountOfContribution = _minAmountOfContribution;
        targetAmount = _targetAmount;
        deadlineTime =block.timestamp+_deadlineTime;

    }
    

    function contribute() public payable 
    {
        
        require(block.timestamp< deadlineTime,"Deadline is passed");
        require(msg.value>minAmountOfContribution,"Not enough amount" );
        if (contributors[msg.sender]==0) 
        {
            NoOfContributors++;
        }
        contributors[msg.sender]+= msg.value;
        raisedAmount+=msg.value;
        
    }
    

    function getcontractBalance() public view returns (uint) 
    {
        return address(this).balance;
    }
    function refund() public
     {
        require(block.timestamp>deadlineTime && raisedAmount<targetAmount,"Refund can't be done");
        require(contributors[msg.sender]>0);
        address payable user =payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier  onlyManager()
    {
        require(msg.sender==manager,"Only Manager can do this operation");
        _;
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"YOu must be contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=targetAmount);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > NoOfContributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }


}