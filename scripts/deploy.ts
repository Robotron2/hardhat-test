import { ethers } from "hardhat"
import * as dotenv from "dotenv"
dotenv.config()

async function main() {
	const [deployer] = await ethers.getSigners()

	console.log("Deploying with account:", deployer.address)

	const RobotronNFT = await ethers.getContractFactory("RobotronNFT")

	const robotronNFT = await RobotronNFT.deploy(deployer.address)

	await robotronNFT.waitForDeployment()

	const address = await robotronNFT.getAddress()

	console.log("NFT deployed to:", address)
}

main().catch((error) => {
	console.error(error)
	process.exitCode = 1
})
