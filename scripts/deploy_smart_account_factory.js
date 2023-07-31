const hre = require('hardhat');
const fs = require('fs');

async function main() {
  const accounts = await hre.ethers.getSigners();
  const UserOperation = await hre.ethers.getContractFactory('UserOperation');
  const userOperation = await UserOperation.deploy();
  await userOperation.deployed();

  const SmartAccountFactory = await hre.ethers.getContractFactory(
    'SmartAccountFactory'
  );
  const smartAccountFactory = await SmartAccountFactory.deploy();

  await smartAccountFactory.deployed();

  console.log(
    `smartAccountFactory contract deployed to ${smartAccountFactory.address}`
  );

  fs.writeFileSync(
    './config.js',
    `const smartAccountFactory = "${smartAccountFactory.address}"
      module.exports = {smartAccountFactory}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
