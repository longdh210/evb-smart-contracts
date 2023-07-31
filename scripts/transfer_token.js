var Web3 = require('web3')
var Account = require('../infor.json')
var key = require('../key.json')

// var web3 = new Web3(
//   new Web3.providers.HttpProvider(
//     "https://opt-goerli.g.alchemy.com/v2/OYewU55MBKeKsGplDHhzVYq2z1a-IFdO"
//   )
// );

// var web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545/"));

const web3 = new Web3(
  new Web3.providers.HttpProvider('https://rpc.sepolia.org/')
)

const main = async () => {
  // const localPrivateKey =
  //   "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
  const signer = web3.eth.accounts.privateKeyToAccount(key.account.privateKey)

  web3.eth.accounts.wallet.add(signer)

  for (let i = 0; i < 150; i++) {
    //the transaction
    const tx = {
      from: signer.address,
      to: Account.infor[i].address,
      value: web3.utils.toWei('0.01', 'ether'),
      // gas: 21000,
      // gasPrice: 500000,
    }

    tx.gas = await web3.eth.estimateGas(tx)

    await web3.eth.sendTransaction(tx).once('transactionHash', (txhash) => {
      console.log(`Mining transaction ...`)
      console.log(`Transaction hash: ${txhash}`)
    })
  }
}

main().catch((error) => {
  console.log(error)
  process.exit = 1
})
