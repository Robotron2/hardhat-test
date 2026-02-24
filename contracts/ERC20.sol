// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ERC20 {
    string constant NAME = "SCHTOKEN";
    string constant SYMBOL = "SCH";
    uint8 constant DECIMAL = 18;
    uint256 _totalSupply;

    mapping(address _certainAddress => uint256 _balanceOfThatAddress) private balances;
    mapping(address _owner => mapping(address _spender => uint256 _amountAllowedToSpend)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public pure returns (string memory) {
        return NAME;
    }

    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }

    function decimal() public pure returns (uint8) {
        return DECIMAL;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        //msg.sender is giving _spender some allowance to spend on their behalf
        require(_spender != address(0), "Can't give allowance to address zero");

        require(_value > 0, "Can't approve zero value");

        require(balances[msg.sender] >= _value, "allowance is greater than your balance");

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        //return the value of the allowance given to a spender
        return allowances[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        //move token from one address balance to another
        require(_to != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(balances[msg.sender] >= _value, "Insufficient funds");

        balances[msg.sender] = balances[msg.sender] - _value; //deduct certain amount of token from the person initiating the transfer

        balances[_to] = balances[_to] + _value; //add the deducted amount of token to the recipient's balance.

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(balances[_from] >= _value, "amount is greater than your balance");

        require(_value <= allowances[_from][msg.sender], "Insufficient allowance");

        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;

        return true;
    }

    function mint(address _owner, uint256 _amount) external {
        require(_owner != address(0), "Can't transfer to address zero");
        _totalSupply = _totalSupply + _amount;
        balances[_owner] = balances[_owner] + _amount;
    }
}
