pragma solidity ^0.4.18;
contract Cashout {
    address public owner;
    
    uint allowance = 100 ether;
    
    mapping (address => uint) cashoutTable;
    
    modifier isOwner {
        require (msg.sender == owner);
        _;
    }
    
    modifier hasBalance(uint etherAmount) {
        require(this.balance >= etherAmount * 1 ether);
        _;
    }
        
    modifier hasAllowance(address user, uint etherAmount) {
        require(cashoutTable[user] + etherAmount * 1 ether <= allowance);
        _;
    }
    
    function Cashout() public {
        owner = msg.sender;
    }
    
    function requestCashout(uint etherAmount) public hasAllowance(msg.sender, etherAmount) hasBalance(etherAmount) {
        uint weiAmount = etherAmount * 1 ether;
        cashoutTable[msg.sender] += weiAmount;
        msg.sender.transfer(weiAmount);
    }
    
    function claimAll() public isOwner {
        owner.transfer(this.balance);
    }
    
    function setAllowance(uint etherAmount) public isOwner {
        allowance = etherAmount * 1 ether;
    }
    
    function deposit() public payable {}
}
