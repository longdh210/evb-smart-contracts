const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const StoreVoting = await hre.ethers.getContractFactory("StoreVoting");
  const storeVoting = await StoreVoting.deploy();

  await storeVoting.deployed();

  console.log(`StoreVoting contract deployed to ${storeVoting.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
