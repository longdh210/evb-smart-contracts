const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const Election = await ethers.getContractFactory("Voting");
  const election = await Election.deploy();

  await election.deployed();

  const SmartAccountFactory = await ethers.getContractFactory(
    "SmartAccountFactory"
  );
  const smartAccountFactory = await SmartAccountFactory.deploy();
  await smartAccountFactory.deployed();

  const UserOperation = await ethers.getContractFactory("UserOperation");
  const userOperation = await UserOperation.deploy();
  await userOperation.deployed();

  const EntryPoint = await ethers.getContractFactory("EntryPoint");
  const entryPoint = await EntryPoint.deploy(
    userOperation.address,
    smartAccountFactory.address
  );
  await entryPoint.deployed();

  console.log(`Voting contract deployed to ${election.address}`);
  console.log(
    `Smart account factory contract deployed to ${smartAccountFactory.address}`
  );
  console.log(`User operation contract deployed to ${userOperation.address}`);
  console.log(`Entry point contract deployed to ${entryPoint.address}`);

  let proposals = ["B", "C", "D"];

  await election.addToParty("A", proposals);
  await election.addToParty("AA", proposals);

  fs.writeFileSync(
    "./config.js",
    `const electionAddress = "${election.address}"
    const smartAccountFactoryAddress = "${smartAccountFactory.address}"
    const userOperationAddress = "${userOperation.address}"
    const entryPointAddress = "${entryPoint.address}"
      module.exports = {electionAddress, smartAccountFactoryAddress, userOperationAddress, entryPointAddress}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
