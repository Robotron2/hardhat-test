// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "interfaces/IERC20.sol";

contract SchoolManagement {
    address public owner;
    uint256 tokenPrice;

    IERC20 public schtoken;

    constructor(address _tokenAddress) {
        schtoken = IERC20(_tokenAddress);
        tokenPrice = 1e15;
        levelFee[Level.LEVEL_100] = 10 ether;
        levelFee[Level.LEVEL_200] = 20 ether;
        levelFee[Level.LEVEL_300] = 30 ether;
        levelFee[Level.LEVEL_400] = 40 ether;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    struct Student {
        uint256 id;
        string name;
        // address studentAddress;
        uint32 level;
        bool hasPaid;
        uint256 feePaid;
        uint256 paymentTimestamp;
    }

    struct Staff {
        string name;
        address staffAddress;
        uint256 salaryPaid;
        bool isSuspended;
        uint256 paymentTimestamp;
    }

    enum Level {
        LEVEL_100,
        LEVEL_200,
        LEVEL_300,
        LEVEL_400
    }

    // mappings
    mapping(address _studentAddress => Student) students;
    mapping(address _staffAddress => Staff) staffs;
    mapping(Level => uint256) public levelFee;

    //arrays
    Student[] public allStudents;
    Staff[] public allStaffs;
    uint256 studentId;

    // ================= CONVERTERS =================

    function getEthSCHConversion(uint256 _ethSent) public view returns (uint256) {
        uint256 amountReturned = (_ethSent * 1e18) / tokenPrice;
        return amountReturned;
    }

    function getSCHEthConversion(uint256 _schAmount) public view returns (uint256) {
        uint256 amountReturned = (_schAmount * tokenPrice) / 1e18;
        return amountReturned;
    }

    // ================= SWAPPINGS =================

    function buySCHToken() external payable {
        require(msg.value > 0, "Send ETH");

        uint256 amountToBuy = getEthSCHConversion(msg.value);

        require(schtoken.balanceOf(address(this)) >= amountToBuy, "Not enough supply");

        bool success = schtoken.transfer(msg.sender, amountToBuy);

        require(success, "Transfer failed");
    }

    function sellSCHToken(uint256 schAmount) external {
        require(schAmount > 0, "Amount must be greater than zero");

        uint256 etherToReceive = getSCHEthConversion(schAmount);

        require(address(this).balance >= etherToReceive, "Not enough ETH in contract");

        // Move SCH from user to this contract
        bool successTransfer = schtoken.transferFrom(msg.sender, address(this), schAmount);
        require(successTransfer, "Token transfer failed");

        // Send ETH to user
        (bool successETH,) = payable(msg.sender).call{value: etherToReceive}("");
        require(successETH, "ETH transfer failed");
    }

    // ================= SCHOOL MANAGEMENT =================

    /*** Register
     * Students buy SCH token from contract via buyToken;
     * Student level determines the fee to be paid;
     * Contract tries to register student that has allowance that is enough to pay fees;
     * Update the studentMapping and studentArray
    */

    function registerStudent(string calldata _name, uint32 _level) external {
        require(bytes(_name).length > 0, "Name required");
        require(_level >= 100 && _level <= 400, "Invalid level");
        require(students[msg.sender].paymentTimestamp == 0, "Already registered");

        studentId = studentId + 1;
        uint256 fee;

        if (_level == 100) {
            fee = levelFee[Level.LEVEL_100];
        } else if (_level == 200) {
            fee = levelFee[Level.LEVEL_200];
        } else if (_level == 300) {
            fee = levelFee[Level.LEVEL_300];
        } else if (_level == 400) {
            fee = levelFee[Level.LEVEL_400];
        } else {
            revert("Unsupported level");
        }

        require(fee > 0, "Fee not set");

        // Check allowance
        require(schtoken.allowance(msg.sender, address(this)) >= fee, "Insufficient allowance");

        // Pull SCH tokens
        bool success = schtoken.transferFrom(msg.sender, address(this), fee);
        require(success, "Payment failed");

        // Store student
        students[msg.sender] = Student({
            id: studentId, name: _name, level: _level, hasPaid: true, feePaid: fee, paymentTimestamp: block.timestamp
        });

        allStudents.push(students[msg.sender]);
    }

    function employStaff(string calldata _name, address _staffAddress) external onlyOwner {
        require(_staffAddress != address(0), "Invalid address");
        require(bytes(_name).length > 0, "Name required");
        require(staffs[_staffAddress].staffAddress == address(0), "Already employed");

        staffs[_staffAddress] =
            Staff({name: _name, staffAddress: _staffAddress, salaryPaid: 0, isSuspended: false, paymentTimestamp: 0});

        allStaffs.push(staffs[_staffAddress]);
    }

    function payStaff(address _staffAddress, uint256 _amount) external onlyOwner {
        require(staffs[_staffAddress].staffAddress != address(0), "Staff not found");
        require(!staffs[_staffAddress].isSuspended, "Staff suspended");
        require(_amount > 0, "Invalid amount");

        require(schtoken.balanceOf(address(this)) >= _amount, "Insufficient SCH");

        bool success = schtoken.transfer(_staffAddress, _amount);
        require(success, "Transfer failed");

        staffs[_staffAddress].salaryPaid += _amount;
        staffs[_staffAddress].paymentTimestamp = block.timestamp;
    }

    function removeStudent(address _studentAddress) external onlyOwner {
        require(students[_studentAddress].paymentTimestamp != 0, "Student not found");

        studentId = students[_studentAddress].id;

        delete students[_studentAddress];

        for (uint256 i = 0; i < allStudents.length; i++) {
            if (allStudents[i].id == studentId) {
                allStudents[i] = allStudents[allStudents.length - 1];
                allStudents.pop();
                break;
            }
        }
    }

    function suspendStaff(address _staffAddress) external onlyOwner {
        require(staffs[_staffAddress].staffAddress != address(0), "Staff not found");

        staffs[_staffAddress].isSuspended = true;
    }

    // ================= GETTER FUNCTIONS =================
    function getStudentById(address _studentAddr) public view returns (Student memory) {
        return students[_studentAddr];
    }

    function getAllStudents() public view returns (Student[] memory) {
        return allStudents;
    }

    function getStaffById(address _staffAddr) public view returns (Staff memory) {
        return staffs[_staffAddr];
    }

    function getAllStaffs() public view returns (Staff[] memory) {
        return allStaffs;
    }

    // ================= FALLBACK FUNCTIONS =================
    receive() external payable {}

    fallback() external payable {}
}