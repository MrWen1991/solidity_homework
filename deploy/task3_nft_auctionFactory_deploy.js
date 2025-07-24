const{ethers,upgrades} = require("hardhat")
const path = require("path");
const fs = require("fs");

module.exports=async({deployments,getNamedAccounts})=>{
  const {save} = deployments;
  const auctionFactoryFactory = await ethers.getContractFactory("NftAuctionFactory");
  const proxy = await upgrades.deployProxy(auctionFactoryFactory,[],{
    initializer: "initialize",
    kind: "uups",
  });

  // console.log("proxy:",proxy);
  await proxy.waitForDeployment();
  const proxyAddress = await proxy.getAddress();
  console.log("Auction Factory deployed to:", proxyAddress);

  const implementAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("Auction Factory Implementation deployed to:", implementAddress);

  const storePath = path.resolve(__dirname, "./.cache","NftAuctionFactoryProxy.json")
  fs.writeFileSync(storePath, JSON.stringify({
    proxyAddress: proxyAddress,
    implementAddress: implementAddress,
    abi: auctionFactoryFactory.interface.format("json")
  }));

  save("NftAuctionFactoryProxy",{
    proxyAddress: proxyAddress,
    implementAddress: implementAddress,
    abi: auctionFactoryFactory.interface.format("json")
  })
}

module.exports.tags = ["deployAuctionFactoryContract"]