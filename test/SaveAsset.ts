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

	/* ================= ETH DEPOSIT ================= */

	describe("ETH Deposit", function () {
		it("Should allow user to deposit ETH", async function () {
			const { saveAsset, user } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("1")

			await saveAsset.connect(user).deposit({ value: amount })

			const saved = await saveAsset.connect(user).getUserSavings()
			expect(saved).to.equal(amount)
		})

		it("Should revert if deposit is zero", async function () {
			const { saveAsset, user } = await loadFixture(deployFixture)

			await expect(saveAsset.connect(user).deposit({ value: 0 })).to.be.revertedWith("Can't deposit zero value")
		})
	})

	/* ================= ERC20 DEPOSIT ================= */
	describe("ERC20 Deposit", function () {
		it("Should allow user to deposit ERC20", async function () {
			const { saveAsset, token, user } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("100")

			// transfer tokens to user
			await token.transfer(user.address, amount)

			// approve contract
			await token.connect(user).approve(await saveAsset.getAddress(), amount)

			// deposit
			await saveAsset.connect(user).depositERC20(amount)

			const saved = await saveAsset.connect(user).getErc20SavingsBalance()

			expect(saved).to.equal(amount)
		})
	})
})
