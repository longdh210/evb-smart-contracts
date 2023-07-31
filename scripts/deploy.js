const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const Voting = await hre.ethers.getContractFactory("Ballot");
  const voting = await Voting.deploy();

  await voting.deployed();

  console.log(`Voting contract deployed to ${voting.address}`);

  let proposals = ["B", "C", "D"];

  await voting.addToParty("A", proposals);
  await voting.addToParty("AA", proposals);

  fs.writeFileSync(
    "./config.js",
    `const votingContractAddress = "${voting.address}"
      module.exports = {votingContractAddress}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
