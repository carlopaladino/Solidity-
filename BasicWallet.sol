pragma solidity ^0.5.13;


contract SharedWallet {
    
    // define the owner of operation 
    address public owner;

    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "you are not allowed");
        _;
    }

    event AllowanceChange(address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount);

    // define allowance to do certain operations
    mapping(address => uint) public allowance;

    function addAllowance(address _who, uint _amount) public onlyOwner{
        emit AllowanceChange(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == owner);
    }


    modifier OwnerOrAllowed(uint _amount) {
        require(isOwner() || allowance[msg.sender] >= _amount, "you are not allowed");
        _; 
    }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChange(_who, msg.sender, allowance[_who], allowance[_who] - (_amount));
        allowance[_who] = allowance[_who] - _amount;
    }


    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);


    function withdrawMoney(address payable _to, uint _amount) public OwnerOrAllowed(_amount){
        require(_amount <= address(this).balance, "there are not enough founds stored in the SM");
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount); 
    }
    
    function () external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
} 
