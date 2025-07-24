const { expect } = require('chai');

const {ethers,deployments} = require('hardhat');

describe("test env", () => {
   // 读取环境变量SEPOLIA_PRIVATE_KEY_THREE
   console.log(process.env["SEPOLIA_PRIVATE_KEY_THREE"]);
   it("deployReceiverContract ", async () => {
      await deployments.fixture("deployReceiverContract");
      const proxy = await deployments.get("CIPPReceiver");
      console.log(proxy)

   });
});