import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai"
import hre from "hardhat"

import { SaveAsset, ERC20 } from "../typechain-types"

describe("SaveAsset", function () {
	async function deployFixture() {
		const [owner, user] = await hre.ethers.getSigners()

		const initialSupply = hre.ethers.parseEther("1000")

		const Token = await hre.ethers.getContractFactory("ERC20")
		const token = await Token.deploy("TestToken", "TT", initialSupply)
		await token.waitForDeployment()

		const SaveAsset = await hre.ethers.getContractFactory("SaveAsset")
		const saveAsset = await SaveAsset.deploy(await token.getAddress())
		await saveAsset.waitForDeployment()

		return { saveAsset, token, owner, user }
	}

	/* ================= DEPLOYMENT ================= */

	describe("Deployment", function () {
		it("Should deploy correctly", async function () {
			const { saveAsset } = await loadFixture(deployFixture)

			const address = await saveAsset.getAddress()
			expect(address).to.not.equal(0)
		})
	})
})
