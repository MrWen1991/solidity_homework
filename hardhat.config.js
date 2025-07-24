require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config(); // 加载 .env 文件

// console.log("SEPOLIA_PRIVATE_KEY_THREE:",process.env["SEPOLIA_PRIVATE_KEY_THREE"]);
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    deployer:0,
    account1: 1,
    account2: 2
  },
  external: {
    deployments: {
      hardhat: ["deploy"],
      localhost: ["deploy"],
      // 其他网络可选
    }
  },
  networks: {
    sepolia: {
      url: process.env["SEPOLIA_URL"] ,
      accounts: [process.env["SEPOLIA_PRIVATE_KEY_THREE"]],
      chainId: 11155111
    }
  }

};