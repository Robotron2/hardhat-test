import { ethers } from "hardhat"
import * as dotenv from "dotenv"
dotenv.config()

async function main() {
	const contractAddress = "0x94cB74927B7B946413c5D90f9a6020DC6693db95"

	const RobotronNFT = await ethers.getContractFactory("RobotronNFT")
	const robotronNFT = RobotronNFT.attach(contractAddress)

	const tx = await robotronNFT.safeMint("0xABf89a4Ae1aBf1690CeEec52Eb4d404586aeDA40", process.env.TOKEN_URI)

	await tx.wait()

	console.log("NFT Minted!")
}

main().catch(console.error)
