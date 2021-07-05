// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Project {
    enum State {
        Fundraising,
        Expired,
        Successful
    }

    address payable public creator;
    uint public amountGoal;
    uint public completeAt; //start project
    uint256 public currentBalance;
    uint public raiseBy;    // end time
    string public title;
    string public description;
    State public state = State.Fundraising; 
    mapping (address => uint) public contributions;

    event FundingReceived(address contributor, uint amount, uint currentTotal);
    // Event that will be emitted whenever the project starter has received the funds
    event CreatorPaid(address recipient);

    // Modifier to check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    // Modifier to check if the function caller is the project creator
    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    constructor(address payable projectStarter, string memory projectTitle, string memory projectDesc, uint fundRaisingDeadline, uint goalAmount) payable{
        creator = projectStarter;
        title = projectTitle;
        description = projectDesc;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
        completeAt = block.timestamp;
        currentBalance = 0;
    }

    function contribute() external inState(State.Fundraising) payable {
        require(msg.sender != creator);
        contributions[msg.sender] = contributions[msg.sender]+ msg.value;
        currentBalance = currentBalance + msg.value;
        emit FundingReceived(msg.sender, msg.value, currentBalance);
        checkIfFundingCompleteOrExpired();
    }

    function checkIfFundingCompleteOrExpired() public {
        if (currentBalance >= amountGoal) {
            state = State.Successful;
            payOut();
        } else if (block.timestamp > raiseBy)  {
            state = State.Expired;
        }
        completeAt = block.timestamp;
    }

    function payOut() internal inState(State.Successful) returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = 0;

        if (creator.send(totalRaised)) {
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            state = State.Successful;
        }

        return false;
    }

    function getRefund() payable public inState(State.Expired) returns (bool){
        require(contributions[msg.sender] > 0);

        address payable addr = payable(msg.sender);
        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;

        if (!addr.send(amountToRefund)) {
            contributions[addr] = amountToRefund;
            return false;
        } else {
            currentBalance = currentBalance - amountToRefund;
        }
        return true;
    }

    function getDetails() public view returns (address payable projectStarter, string memory projectTitle, string memory projectDesc, uint256 deadline, State currentState, uint256 currentAmount, uint256 goalAmount) {
        projectStarter = creator;
        projectTitle = title;
        projectDesc = description;
        deadline = raiseBy;
        currentState = state;
        currentAmount = currentBalance;
        goalAmount = amountGoal;
    }
}
