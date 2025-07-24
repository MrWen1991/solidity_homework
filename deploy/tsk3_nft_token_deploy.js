const { ethers } = require("hardhat");
const path = require("path");
const fs = require("fs");

module.exports = async ({ deployments, getNamedAccounts }) => {
  const { deployer } = getNamedAccounts();
  const { save } = deployments;
  const nftFactory = await ethers.getContractFactory("NftToken");
  const nftContract = await nftFactory.deploy();
  await nftContract.waitForDeployment();
  const nftContractAddress = await nftContract.getAddress();
  console.log("NFT Contract deployed to:", nftContractAddress);

  // 保存合约信息
  const storePath = path.resolve(__dirname, "./.cache", "NftToken.json");
  fs.writeFileSync(storePath, JSON.stringify({
    contractAddress: nftContractAddress,
    abi: nftFactory.interface.format("json")
  }));

  save("NftToken", {
    contractAddress: nftContractAddress,
    abi: nftFactory.interface.format("json")
  });
};

module.exports.tags = ["deployNftContract"];

// contract address : 0x5FbDB2315678afecb367f032d93F642f64180aa3