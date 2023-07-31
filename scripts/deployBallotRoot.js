const hre = require('hardhat')
const fs = require('fs')

async function main() {
  const Voting = await hre.ethers.getContractFactory('FromL2_ControlL1')
  const voting = await Voting.deploy()

  await voting.deployed()

  console.log(`Voting contract deployed to ${voting.address}`)

  let proposals = ['B', 'C', 'D']
  const root =
    '0xecc5cebb1371d1f757d477a80a68f16290e6784fc30d3d470010efd4c4d7cf17'

  await voting.addToParty('A', proposals, root)
  await voting.addToParty('AA', proposals, root)

  fs.writeFileSync(
    './configVotingRoot.js',
    `const votingContractRootAddress = "${voting.address}"
      module.exports = {votingContractRootAddress}`
  )
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
