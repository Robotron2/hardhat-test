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

	/* ================= TRANSFER ================= */

	describe("ERC20 transfer", function () {
		it("Should transfer tokens successfully", async function () {
			const { token, owner, user } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("100")

			await expect(token.transfer(user.address, amount))
				.to.emit(token, "Transfer")
				.withArgs(owner.address, user.address, amount)

			expect(await token.balanceOf(user.address)).to.equal(amount)
		})

		it("Should revert if transferring zero", async function () {
			const { token, user } = await loadFixture(deployFixture)

			await expect(token.transfer(user.address, 0)).to.be.revertedWith("Can't send zero value")
		})

		it("Should revert if insufficient balance", async function () {
			const { token, user } = await loadFixture(deployFixture)

			const bigAmount = hre.ethers.parseEther("2000")

			await expect(token.connect(user).transfer(user.address, bigAmount)).to.be.revertedWith("Insufficient funds")
		})
	})

	//   /* ================= APPROVE ================= */

	describe("ERC20 approve", function () {
		it("Should approve allowance correctly", async function () {
			const { token, owner, spender } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("50")

			await expect(token.approve(spender.address, amount))
				.to.emit(token, "Approval")
				.withArgs(owner.address, spender.address, amount)

			expect(await token.allowance(owner.address, spender.address)).to.equal(amount)
		})
	})

	/* ================= TRANSFER FROM ================= */

	describe("ERC20 transferFrom", function () {
		it("Should transfer using allowance", async function () {
			const { token, owner, user, spender } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("100")

			// approve spender
			await token.approve(spender.address, amount)

			// spender transfers from owner to user
			await token.connect(spender).transferFrom(owner.address, user.address, amount)

			expect(await token.balanceOf(user.address)).to.equal(amount)
			expect(await token.allowance(owner.address, spender.address)).to.equal(0)
		})

		it("Should revert if no allowance", async function () {
			const { token, owner, user, spender } = await loadFixture(deployFixture)

			const amount = hre.ethers.parseEther("100")

			await expect(token.connect(spender).transferFrom(owner.address, user.address, amount)).to.be.revertedWith(
				"Insufficient allowance",
			)
		})
	})
})
