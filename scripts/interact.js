const EntryPointContract = require("../artifacts/contracts/TestAA/EntryPoint.sol/EntryPoint.json");
const UserOperationContract = require("../artifacts/contracts/TestAA/UserOperation.sol/UserOperation.json");
const SmartAccountFactoryContract = require("../artifacts/contracts/TestAA/SmartAccountFactory.sol/SmartAccountFactory.json");
const {
  entryPointAddress,
  userOperationAddress,
  smartAccountFactoryAddress,
} = require("../config.js");
const { ethers } = require("hardhat");

let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");

async function main() {
  const [owner] = await ethers.getSigners();

  let smartAccountFactory = new ethers.Contract(
    smartAccountFactoryAddress,
    SmartAccountFactoryContract.abi,
    provider
  );

  const txCreateSmartAccount = await smartAccountFactory
    .connect(owner)
    .createSmartAccount(owner.address, userOperationAddress);

  let receipt = await txCreateSmartAccount.wait();
  console.log(receipt);
  const accounts = await smartAccountFactory.getDeployedAccounts();
  console.log("accounts:", accounts);
  //   let smartAccountInfo = await receipt.events?.filter((x) => {
  //     return x.event == "SmartAccountCreated";
  //   });
  //   let smartAccountAddress = smartAccountInfo[0].args[1];
  //   console.log("smartAccountAddress", smartAccountAddress);

  //   let smartAccount = await ethers.getContractAt(
  //     "SmartAccount",
  //     smartAccountAddress
  //   );
}

main();
