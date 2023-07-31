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

  const DeployBallot = await hre.ethers.getContractFactory('DeployBallot');
  const deployBallot = await DeployBallot.deploy(accounts[0].address);

  await deployBallot.deployed();

  console.log(`
  userOperation contract deployed to ${userOperation.address}
  DeployBallot contract deployed to ${deployBallot.address}
  smartAccountFactory contract deployed to ${smartAccountFactory.address}
  `);

  fs.writeFileSync(
    './config.js',
    `const deployBallot = "${deployBallot.address}"
    const userOperation = "${userOperation.address}"
    const smartAccountFactory = "${smartAccountFactory.address}"
      module.exports = {deployBallot, userOperation, smartAccountFactory}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
