// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MultisigWallet {
    address[3] public members;
    uint256 public requiredConfirmations;

    constructor(address[3] memory _members, uint256 _required) {
        members = _members;
        requiredConfirmations = _required;
    }

    struct Transaction {
        address _to;
        uint256 _value;
        bool _status;
    }

    Transaction[] public transactions;

    mapping(uint256 _txId => mapping(address _owner => bool status)) public confirmations;

    function getAllTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }

    function submitTransaction(address _recipient, uint256 _value) public {
        //find owner
        bool ownerFound;
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == msg.sender) {
                ownerFound = true;
            }
        }
        //once found, cereate txn
        require(ownerFound == true, "Not an owner");
        transactions.push(Transaction(_recipient, _value, false));
        confirmations[transactions.length - 1][msg.sender] = true;
    }

    function confirmTransaction(uint256 _txnIndex) public returns (bool res) {
        bool ownerFound;
        uint256 numberOfConfirmations;
        // check for the msg.sender is among members
        for (uint256 i = 0; i < members.length; i++) {
            if (msg.sender == members[i]) {
                ownerFound = true;
                confirmations[_txnIndex][msg.sender] = true;
            }
            if (confirmations[_txnIndex][members[i]] == true) {
                numberOfConfirmations++;
            }
        }
        require(ownerFound == true, "Not an owner");
        if (numberOfConfirmations >= requiredConfirmations && transactions[_txnIndex]._status == false) {
            transactions[_txnIndex]._status = true;
            uint256 amountToTransfer = transactions[_txnIndex]._value;
            address recipient = transactions[_txnIndex]._to;
            // payable(transactions[_txnIndex]._to).transfer();
            (bool result,) = payable(recipient).call{value: amountToTransfer}("");
            return result;
        }
    }

    receive() external payable {}
}
