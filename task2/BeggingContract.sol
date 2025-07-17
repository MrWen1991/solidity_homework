// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/access/Ownable.sol";

// 合约地址： 0xc42D07926672b1817C9CcE321C8B976Eeb9747BD
contract BeggingContract is Ownable{
    mapping(address => uint256) public donations;
    constructor() Ownable(msg.sender) {
    }

    function donate()public payable{
        require(msg.value > 0, "Donation must be greater than 0");
        donations[msg.sender] += msg.value;
    }

    function withdraw()public onlyOwner{
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    function getDonation(address donor) public view returns(uint256) {
        return donations[donor];
    }

}