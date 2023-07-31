const { ethers } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("dApp Flow with Account Abstraction", function () {
  let smartAccountFactory;
  let userOperation;
  let smartAccount;
  let entryPoint;
  const hre = require("hardhat");
  const fs = require("fs");

  async function deployTokenFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Election = await ethers.getContractFactory("Voting");
    const election = await Election.deploy();
    await election.deployed();

    const SmartAccountFactory = await ethers.getContractFactory(
      "SmartAccountFactory"
    );
    smartAccountFactory = await SmartAccountFactory.deploy();
    await smartAccountFactory.deployed();

    const UserOperation = await ethers.getContractFactory("UserOperation");
    userOperation = await UserOperation.deploy();
    await userOperation.deployed();

    const EntryPoint = await ethers.getContractFactory("EntryPoint");
    entryPoint = await EntryPoint.deploy(
      userOperation.address,
      smartAccountFactory.address
    );
    await entryPoint.deployed();

    // await smartAccountFactory.createSmartAccount(owner.address);
    const txCreateSmartAccount = await smartAccountFactory.createSmartAccount(
      owner.address,
      userOperation.address
    );

    let receipt = await txCreateSmartAccount.wait();
    console.log(receipt);
    let smartAccountInfo = await receipt.events?.filter((x) => {
      return x.event == "SmartAccountCreated";
    });
    let smartAccountAddress = smartAccountInfo[0].args[1];
    // console.log("userAddress", userAddress);

    smartAccount = await ethers.getContractAt(
      "SmartAccount",
      smartAccountAddress
    );
    console.log(
      "deployedAccount:",
      await smartAccountFactory.getDeployedAccounts()
    );

    return { election, smartAccount, userOperation, entryPoint, owner };
  }

  describe("Deployment", function () {
    it("should request to vote and verify successfully", async function () {
      const { election, smartAccount, userOperation, entryPoint, owner } =
        await loadFixture(deployTokenFixture);

      let proposals = ["B", "C", "D"];

      await election.addToParty("A", proposals);
      await election.addToParty("AA", proposals);

      // console.log("userOperation:", userOperation.address);
      // Request to vote
      const signature = await entryPoint.handleVoteRequest(
        smartAccount.address,
        election.address,
        0,
        0,
        "vote",
        111
      );

      const sigHash = await owner.signMessage(ethers.utils.arrayify(signature));

      expect(
        await entryPoint.handleVerifySign(
          smartAccount.address,
          owner.address,
          election.address,
          0,
          0,
          "vote",
          111,
          sigHash
        )
      ).to.equal(true);
    });
  });
});
