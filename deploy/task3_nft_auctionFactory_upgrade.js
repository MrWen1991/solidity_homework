const{ethers,upgrades} = require("hardhat")
const path = require("path");
const fs = require("fs");
// implAddress1: 0x5FbDB2315678afecb367f032d93F642f64180aa3
// implAddress2: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

module.exports=async({deployments,getNamedAccounts})=>{
  const{save} = deployments;
  // 读取NftAuctionFactoryProxy合约 deploy/.cache/NftAuctionFactoryProxy.json
  const readPath = path.resolve(__dirname, './.cache/', 'NftAuctionFactoryProxy.json');
  const data = fs.readFileSync(readPath,'utf8');
  const {proxyAddress, implementAddress, abi} = JSON.parse(data);

  const auctionFactoryV2Factory = await ethers.getContractFactory("NftAuctionFactoryV2");
  // const proxy = await upgrades.upgradeProxy(proxyAddress, auctionFactoryV2Factory);
  // 如果逻辑一样，强制升级，否则implementAddress和之前的一样，复用之前的逻辑合约，而不会部署新的实现合约
  const proxy = await upgrades.forceImport(proxyAddress, auctionFactoryV2Factory);

  console.log("proxy:",proxy);
  await proxy.waitForDeployment();
  const proxyAddress2 = await proxy.getAddress();
  console.log("Auction Factory deployed to:", proxyAddress2);

  const implementAddress2 = await upgrades.erc1967.getImplementationAddress(proxyAddress2);
  console.log("Auction Factory Implementation deployed to:", implementAddress2);

  const storePath = path.resolve(__dirname, "./.cache","NftAuctionFactoryProxy.json")
  fs.writeFileSync(storePath, JSON.stringify({
    proxyAddress: proxyAddress2,
    implementAddress: implementAddress2,
    abi: auctionFactoryV2Factory.interface.format("json")
  }));

  save("NftAuctionFactoryProxy",{
    proxyAddress: proxyAddress2,
    implementAddress: implementAddress2,
    abi: auctionFactoryV2Factory.interface.format("json")
  })
}

module.exports.tags = ["upgradeAuctionFactoryContract"]