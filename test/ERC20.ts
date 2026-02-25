import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai"
import hre from "hardhat"

describe("ERC20", function () {
	async function deployFixture() {
		const [owner, user, spender] = await hre.ethers.getSigners()

		const initialSupply = hre.ethers.parseEther("1000")

		const Token = await hre.ethers.getContractFactory("ERC20")
		const token = await Token.deploy("TestToken", "TT", initialSupply)
		await token.waitForDeployment()

		return { token, owner, user, spender, initialSupply }
	}

	/* ================= DEPLOYMENT ================= */

	describe("Deployment", function () {
		it("Should set name and symbol correctly", async function () {
			const { token } = await loadFixture(deployFixture)

			expect(await token.name()).to.equal("TestToken")
			expect(await token.symbol()).to.equal("TT")
		})

		it("Should set decimals to 18", async function () {
			const { token } = await loadFixture(deployFixture)

			expect(await token.decimals()).to.equal(18)
		})

		it("Should mint initial supply to owner", async function () {
			const { token, owner, initialSupply } = await loadFixture(deployFixture)

			expect(await token.totalSupply()).to.equal(initialSupply)
			expect(await token.balanceOf(owner.address)).to.equal(initialSupply)
		})
	})
})
