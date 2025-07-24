const{ethers} = require("hardhat");
const path = require("path");
const fs = require("fs");

module.exports = async({deployments, getNamedAccounts}) => {
  const {deployer} = getNamedAccounts();
  const {save} = deployments;
  const receiverFactory = await ethers.getContractFactory("CIPPReceiver");
  const routerAddress = "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59";

  const readPath = path.resolve(__dirname, "./.cache", "NftAuctionFactoryProxy.json");
  const data = fs.readFileSync(readPath, "utf-8");
  const{proxyAddress,implementAddress,abi} = JSON.parse(data);

  // const NftAuctionFactoryProxy = await deployments.get("NftAuctionFactoryProxy");
  console.log("NftAuctionFactoryProxy:", proxyAddress);
  // const factoryAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const factoryAddress = proxyAddress;
  const receiverContract = await receiverFactory.deploy(routerAddress,factoryAddress);
  await receiverContract.waitForDeployment();
  const receiverContractAddress = await receiverContract.getAddress();
  console.log("Receiver Contract deployed to:", receiverContractAddress);

  // 保存合约信息
  const storePath = path.resolve(__dirname, "./.cache","CIPPReceiver.json");
  fs.writeFileSync(storePath, JSON.stringify({
    contractAddress: receiverContractAddress,
    abi: receiverFactory.interface.format("json")
  }));

  save("CIPPReceiver", {
    address: receiverContractAddress,
    abi: receiverFactory.interface.format('json')
  });
}

module.exports.tags = ["deployReceiverContract"];
