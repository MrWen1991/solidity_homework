const { ethers } = require("hardhat");

async function main() {
  const factoryAddress = "0x705938c4f36E8E27D6483ec0F465EfC5d9457d8C"; // 你的合约地址
  const factory = await ethers.getContractAt("NftAuctionFactoryV2", factoryAddress);

  const nftAddress = "0x5D5f01a61C20368c5c94F786b460b1F7d1D4d5bD";
  // 调用 createAuction
  try {
    const tx = await factory.createAuction(
      nftAddress,
      1,
      ethers.parseEther("1"),
      3600
    );

    console.log("Transaction sent:", tx.hash);
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    // 获取创建的拍卖地址
    const auctionAddress = await factory.getAuction(nftAddress, 1);
    console.log("Created auction address:", auctionAddress);

    const auctionAddresses = await factory.getAuctions();
    console.log("auctionsAddress:",auctionAddresses)
  } catch (error) {
    console.error("Error:", error.message);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
