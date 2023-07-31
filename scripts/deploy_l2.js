const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const ExampleL2 = await hre.ethers.getContractFactory("ExampleL2");
  const exampleL2 = await ExampleL2.deploy();

  await exampleL2.deployed();

  console.log(`ExampleL2 contract deployed to ${exampleL2.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
