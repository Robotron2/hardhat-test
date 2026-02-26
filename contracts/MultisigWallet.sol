// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultisigWallet {
    //Erross
    error NotOwner();
    error InvalidOwner();
    error DuplicateOwner();
    error InvalidRequiredConfirmations();
    error TransactionDoesNotExist();
    error AlreadyConfirmed();
    error AlreadyExecuted();
    error InsufficientConfirmations();
    error TransferFailed();
    error InsufficientBalance();

    //Events
    event Deposit(address indexed sender, uint256 amount);
    event TransactionSubmitted(uint256 indexed txId, address indexed to, uint256 value);
    event TransactionConfirmed(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId);

    //State variabkes
    address[3] public members;
    uint256 public requiredConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    Transaction[] public transactions;

    // txId => owner => confirmed
    mapping(uint256 => mapping(address => bool)) public confirmations;

    //Modifiers
    modifier onlyOwner() {
        if (!_isOwner(msg.sender)) revert NotOwner();
        _;
    }

    modifier txExists(uint256 _txId) {
        if (_txId >= transactions.length) revert TransactionDoesNotExist();
        _;
    }

    modifier notExecuted(uint256 _txId) {
        if (transactions[_txId].executed) revert AlreadyExecuted();
        _;
    }

    //Constructor
    constructor(address[3] memory _members, uint256 _required) {
        if (_required == 0 || _required > _members.length) {
            revert InvalidRequiredConfirmations();
        }

        for (uint256 i = 0; i < _members.length; i++) {
            if (_members[i] == address(0)) revert InvalidOwner();

            // check duplicates
            for (uint256 j = i + 1; j < _members.length; j++) {
                if (_members[i] == _members[j]) revert DuplicateOwner();
            }
        }

        members = _members;
        requiredConfirmations = _required;
    }

    //

    function submitTransaction(address _to, uint256 _value) external onlyOwner {
        if (_to == address(0)) revert InvalidOwner();

        uint256 txId = transactions.length;

        transactions.push(Transaction({to: _to, value: _value, executed: false}));

        confirmations[txId][msg.sender] = true;

        emit TransactionSubmitted(txId, _to, _value);
        emit TransactionConfirmed(txId, msg.sender);
    }

    function confirmTransaction(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        if (confirmations[_txId][msg.sender]) revert AlreadyConfirmed();

        confirmations[_txId][msg.sender] = true;

        emit TransactionConfirmed(_txId, msg.sender);
    }

    function executeTransaction(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        uint256 count = _countConfirmations(_txId);

        if (count < requiredConfirmations) revert InsufficientConfirmations();

        Transaction storage txn = transactions[_txId];

        if (address(this).balance < txn.value) revert InsufficientBalance();

        txn.executed = true;

        (bool success,) = payable(txn.to).call{value: txn.value}("");

        if (!success) revert TransferFailed();

        emit TransactionExecuted(_txId);
    }

    function getAllTransactions() external view returns (Transaction[] memory) {
        return transactions;
    }

    //helper s

    function _isOwner(address _addr) internal view returns (bool) {
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function _countConfirmations(uint256 _txId) internal view returns (uint256 count) {
        for (uint256 i = 0; i < members.length; i++) {
            if (confirmations[_txId][members[i]]) {
                count++;
            }
        }
    }

    //receive
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}
