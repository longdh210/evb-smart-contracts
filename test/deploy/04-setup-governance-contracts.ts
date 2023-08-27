import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DeployFunction } from "hardhat-deploy/types"

import { ADDRESS_ZERO } from "../helper-hardhat-config"
// @ts-ignore
import { ethers } from "hardhat"

const setupContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    // @ts-ignore
    const { getNamedAccounts, deployments } = hre
    const { log } = deployments
    const { deployer } = await getNamedAccounts()

    const timeLock = await ethers.getContractAt("TimeLock", deployer)
    const governor = await ethers.getContractAt("GovernorContract", deployer)
    console.log(timeLock.address);

    log("----------------------------------------------------")
    log("Setting up contracts for roles...")
    // would be great to use multicall here...
    const proposerRole = await timeLock.PROPOSER_ROLE()
    console.log("proposerRole:", proposerRole)
    const executorRole = await timeLock.EXECUTOR_ROLE()
    const adminRole = await timeLock.TIMELOCK_ADMIN_ROLE()

    const proposerTx = await timeLock.grantRole(proposerRole, governor.address)
    await proposerTx.wait(1)
    const executorTx = await timeLock.grantRole(executorRole, ADDRESS_ZERO)
    await executorTx.wait(1)
    const revokeTx = await timeLock.revokeRole(adminRole, deployer)
    await revokeTx.wait(1)
    // Guess what? Now, anything the timelock wants to do has to go through the governance process!
}

export default setupContracts
setupContracts.tags = ["all", "setup"]