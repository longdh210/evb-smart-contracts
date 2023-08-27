const hre = require('hardhat');
const { ethers } = require('hardhat');
const {
  MIN_DELAY,
  QUORUM_PERCENTAGE,
  VOTING_PERIOD,
  VOTING_DELAY,
  ADDRESS_ZERO,
} = require('../helper-hardhat-config');
const fs = require('fs');

async function main() {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0].address;
  const GovernanceToken = await ethers.getContractFactory('GovernanceToken');
  const governanceToken = await GovernanceToken.deploy();

  await governanceToken.deployed();

  console.log(`Governance token deployed to ${governanceToken.address}`);

  await delegate(governanceToken.address, deployer);
  console.log('Delegated!');

  const TimeLock = await ethers.getContractFactory('TimeLock');
  const timeLock = await TimeLock.deploy(MIN_DELAY, [], [], deployer);

  await timeLock.deployed();

  console.log(`Time lock deployed to ${timeLock.address}`);

  const GovernorContract = await ethers.getContractFactory('GovernorContract');
  const governorContract = await GovernorContract.deploy(
    governanceToken.address,
    timeLock.address,
    QUORUM_PERCENTAGE,
    VOTING_PERIOD,
    VOTING_DELAY
  );

  console.log(`Governor contract deployed to ${governorContract.address}`);

  const proposerRole = await timeLock.PROPOSER_ROLE();
  const executorRole = await timeLock.EXECUTOR_ROLE();
  const adminRole = await timeLock.TIMELOCK_ADMIN_ROLE();

  const proposerTx = await timeLock.grantRole(
    proposerRole,
    governorContract.address
  );
  await proposerTx.wait(1);
  const executorTx = await timeLock.grantRole(executorRole, ADDRESS_ZERO);
  await executorTx.wait(1);
  const revokeTx = await timeLock.revokeRole(adminRole, deployer);
  await revokeTx.wait(1);
  console.log('Setup governance contract successfully!!!');

  const Invest = await ethers.getContractFactory('Invest');
  const invest = await Invest.deploy();
  console.log(`Invest contract deployed to ${invest.address}`);

  const transferTx = await invest.transferOwnership(timeLock.address);
  await transferTx.wait();
  console.log('Setup invest contract successfully!!!');

  fs.writeFileSync(
    './config.js',
    `export const governanceTokenAddress = "${governanceToken.address}"
    export const timeLockAddress = "${timeLock.address}"
    export const governorContractAddress = "${governorContract.address}"
    export const investAddress = "${invest.address}"
      module.exports = {governanceTokenAddress, timeLockAddress, governorContractAddress, investAddress}`
  );
}

const delegate = async (governanceTokenAddress, delegatedAccount) => {
  const governanceToken = await ethers.getContractAt(
    'GovernanceToken',
    governanceTokenAddress
  );
  const transactionResponse = await governanceToken.delegate(delegatedAccount);
  await transactionResponse.wait();
  console.log(
    `Checkpoints: ${await governanceToken.numCheckpoints(delegatedAccount)}`
  );
};

main();
