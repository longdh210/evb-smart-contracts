var { votingContractAddress } = require("../config");
var VotingContract = require("../artifacts/contracts/Voting.sol/Ballot.json");
var Web3 = require("web3");
const { ethers } = require("hardhat");

var web3 = new Web3("http://127.0.0.1:8545/");
let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");

const main = async () => {
    const [sender, addr1, addr2] = await ethers.getSigners();
    let accounts = [];

    let votingContract = new ethers.Contract(
        votingContractAddress,
        VotingContract.abi,
        provider
    );

    // let votingContract = new web3.eth.Contract(
    //     VotingContract.abi,
    //     votingContractAddress
    // );

    for (let i = 0; i < 50; i++) {
        let accountObject = web3.eth.accounts.create();
        accounts.push(accountObject);
    }

    for (let i = 0; i < 50; i++) {
        await web3.eth.sendTransaction({
            from: sender.address,
            to: accounts[i].address,
            value: web3.utils.toWei("0.01", "ether"),
            gasLimit: 21000,
            gasPrice: 20000000000,
        });
    }
    let balance = await web3.eth.getBalance(accounts[0].address);

    for (let i = 0; i < 50; i++) {
        await votingContract
            .connect(sender)
            .giveRightToVote(0, accounts[i].address);
    }

    for (let i = 0; i < 50; i++) {
        let wallet = new ethers.Wallet(accounts[i].privateKey, provider);
        await votingContract.connect(wallet).vote(0, 0);
        let balance2 = await web3.eth.getBalance(wallet.address);
        console.log(balance - balance2);
    }
};

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
