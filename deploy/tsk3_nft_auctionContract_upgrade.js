const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async ({ deployments, getNamedAccounts }) => {
  const { deployer } = getNamedAccounts();
  // 根据auctionFactory 获取所有的auctionContractProxy，挨个升级
  // 读取NftAuctionFactoryProxy合约 deploy/.cache/NftAuctionFactoryProxy.json
  const readPath = path.resolve(__dirname, "./.cache/", "NftAuctionFactoryProxy.json");
  const data = fs.readFileSync(readPath, "utf8");
  const { proxyAddress, implementAddress, abi } = JSON.parse(data);

  const { save } = deployments;
  const auctionFactory = await ethers.getContractAt("NftAuctionFactoryV2", proxyAddress);
  console.log("auctionFactory:", auctionFactory);

  // 将auctionFactory转化成NftAuctionFactory类型，并调用

  const auctionV2 = await ethers.getContractFactory("NftAuctionContractV2");

  // const nftAddress = "0x5D5f01a61C20368c5c94F786b460b1F7d1D4d5bD";
  // const auctionAddress1 = await auctionFactory.createAuction( nftAddress, 1,100,10*60);
  // console.log("created auctionAddress:", auctionAddress1)

  const auctions = await auctionFactory.getAuctions();

  console.log("auctions:", auctions)

  for (let i = 0; i < auctions.length; i++) {
    const auction = auctions[i];
    const auctionAddress = auction;
    console.log("auctionAddress:", auctionAddress)

    // registry proxy
    await upgrades.forceImport(auctionAddress, auctionV2)

    // upgrade proxy
    const updateProxy = await upgrades.connect().upgradeProxy(auctionAddress, auctionV2);
    console.log("updateProxy:", updateProxy);
    // await updateProxy.waitForDeployment();

    const auctionImplAddress = await upgrades.erc1967.getImplementationAddress(auctionAddress);
    console.log("auctionImplAddress:", auctionImplAddress);
    // 取auctionAddress的16进制前6位字节
    const prefix = auctionAddress.slice(2, 10);

    // 保存合约信息
    const storePath = path.resolve(__dirname, "./.cache", "NftAuctionContractProxy-", prefix ,".json");
    fs.writeFileSync(storePath, JSON.stringify({
      proxyAddress: auctionAddress,
      implentAddress: auctionImplAddress,
      abi: auctionV2.interface.format("json")
    }));

    save("NftAuctionFactoryProxy-"+prefix ,{
      proxyAddress: auctionAddress,
      implentAddress: auctionImplAddress,
      abi: auctionV2.interface.format("json")
    })
    break;
  }




};

module.exports.tags = ["UpgradeAuctionContract"];