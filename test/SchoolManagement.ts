import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai"
import hre from "hardhat"

describe("SchoolManagement", function () {
	async function deployFixture() {
		//get signers
		const [propietor, student, staff] = await hre.ethers.getSigners()

		//initialSupply
		const initialSupply = hre.ethers.parseEther("1000")

		// ERC20 Token Contract Instance
		const Token = await hre.ethers.getContractFactory("ERC20")

		// ERC20 Token Instance Deploy
		const token = await Token.deploy("SchoolToken", "SCH", initialSupply)

		// Wait for token to deploy
		await token.waitForDeployment()

		const SchoolManagement = await hre.ethers.getContractFactory("SchoolManagement")
		const schoolManagement = await SchoolManagement.deploy(await token.getAddress())
		await schoolManagement.waitForDeployment()

		return { schoolManagement, token, propietor, student, staff }
	}

	describe("Register student", function () {
		it("should register student successfully", async function () {
			const { schoolManagement, token, propietor, student } = await loadFixture(deployFixture)
		})
	})
})
