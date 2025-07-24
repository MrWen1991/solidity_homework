// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/** 
作业 1：ERC20 代币
任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求：
合约包含以下标准 ERC20 功能：
balanceOf：查询账户余额。
transfer：转账。
approve 和 transferFrom：授权和代扣转账。
使用 event 记录转账和授权操作。
提供 mint 函数，允许合约所有者增发代币。
提示：
使用 mapping 存储账户余额和授权信息。
使用 event 定义 Transfer 和 Approval 事件。
部署到sepolia 测试网，导入到自己的钱包
**/

// 代币合约地址 0x615bD93a75d4d53994b643d4D03A324E8aD2c2a6

abstract contract MyERC20Contract is ERC20, Ownable{
    mapping(address => uint256) private _balances;
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        mint(msg.sender, 10000 * 10 ** decimals()); // 初始发行量为 1 万个代币
    }
    function mint(address recipient, uint256 amount) public onlyOwner{
        require(recipient != address(0), "ERC20: mint to the zero address");
        require(amount > 0, "ERC20: mint amount must be greater than zero");
        _mint(recipient, amount);
    }
}
