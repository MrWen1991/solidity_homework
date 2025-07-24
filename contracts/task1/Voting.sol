// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// ✅ 创建一个名为Voting的合约，包含以下功能：
// 一个mapping来存储候选人的得票数
// 一个vote函数，允许用户投票给某个候选人
// 一个getVotes函数，返回某个候选人的得票数
// 一个resetVotes函数，重置所有候选人的得票数

contract Voting{
    mapping(address=>uint256)public votes;
    mapping(address => bool) public exists;
    address[] public addresses;

    function vote(address addr)public returns(string memory){
        votes[addr] += 1;
        if(!exists[addr]){
            addresses.push(addr);
            exists[addr] = true;
        }
        return "successfully vote";
    }
    
    function getVotes(address addr) public view returns(uint256){
        return votes[addr];
    }

    function resetVotes() public returns(string memory res){
        

        for(uint256 i=0;i< addresses.length; i++){
            delete votes[addresses[i]]; 
            exists[addresses[i]] = false;
        }
    
        delete addresses ;
        res = "successfully";
    }
}