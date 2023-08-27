import "@typechain/hardhat"
import "@nomiclabs/hardhat-waffle"
import "@nomiclabs/hardhat-etherscan"
import "@nomiclabs/hardhat-ethers"
import "hardhat-gas-reporter"
import "dotenv/config"
import "solidity-coverage"
import "hardhat-deploy"
import { HardhatUserConfig } from "hardhat/config"
const { version } = require('ethers')
const key = require('./key.json')

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    polygonMumbai: {
      chainId: 80001,
      url: 'https://polygon-mumbai.g.alchemy.com/v2/EAAlM0-rm4pHavxVcH0ZV9Sm0JYhxoRf',
      accounts: [key.account.privateKey],
    },
    goerli: {
      chainId: 5,
      url: 'https://eth-goerli.g.alchemy.com/v2/DfH8hZGjc2FWzIzbEGxrg21UPkDmqK6w',
      accounts: [key.account.privateKey],
    },
    bsc: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: 97,
      accounts: [key.account.privateKey],
    },
    optimismGoerli: {
      chainId: 420,
      url: 'https://opt-goerli.g.alchemy.com/v2/OYewU55MBKeKsGplDHhzVYq2z1a-IFdO',
      accounts: [key.account.privateKey],
    },
    zksync: {
      chainId: 280,
      url: 'https://testnet.era.zksync.dev',
      accounts: [key.account.privateKey],
    },
    sepolia: {
      chainId: 11155111,
      url: 'https://eth-sepolia.g.alchemy.com/v2/u24_snqkQZKIuaapWJBPm2abVHEbjwWe',
      accounts: [key.account.privateKey],
    },
  },
  etherscan: {
    // apiKey: "GU9I8IGYKY43RYC758W6E5K69Y5FJIRJ98",
    apiKey: {
      polygonMumbai: 'QKJEMAGZ31PSKFG5XZFTIW7KWV2M1135RK',
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    // coinmarketcap: COINMARKETCAP_API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
  solidity: {
    version: '0.8.13',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
}

export default config
