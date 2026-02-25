import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai"
import hre from "hardhat"

import { MultisigWallet } from "../typechain-types"

describe("MultisigWallet", function () {
	async function deployFixture() {
		//get signers
		const [member1, member2, member3, outsider] = await hre.ethers.getSigners()
		const owners = [await member1.getAddress(), await member2.getAddress(), await member3.getAddress()]

		const MultisigWalletFactory = await hre.ethers.getContractFactory("MultisigWallet")
		const multisigWallet = (await MultisigWalletFactory.deploy(
			[await member1.getAddress(), await member2.getAddress(), await member3.getAddress()],
			2,
		)) as MultisigWallet

		await multisigWallet.waitForDeployment()

		return { multisigWallet, member1, member2, member3, outsider }
	}

	describe("SubmitTxn", function () {
		it("submit transaction successfully", async function () {
			const { multisigWallet, member1, outsider } = await loadFixture(deployFixture)
			const amountToSend = hre.ethers.parseEther("20")
			const recipient = await outsider.getAddress()
			await multisigWallet.connect(member1).submitTransaction(recipient, amountToSend)
			const txns = await multisigWallet.getAllTransactions()
			expect(txns[0]._status).to.equal(false)
		})
		it("should not allow unknown member", async function () {
			const { multisigWallet, member1, outsider } = await loadFixture(deployFixture)
			const amountToSend = hre.ethers.parseEther("20")
			const recipient = await member1.getAddress()

			await expect(
				multisigWallet.connect(outsider).submitTransaction(recipient, amountToSend),
			).to.be.revertedWith("Not an owner")
		})
	})

	describe("confirmTxn", function () {
		async function setupTransactionFixture() {
			const { multisigWallet, member1, member2, member3 } = await loadFixture(deployFixture)

			const amountToConfirm = hre.ethers.parseEther("2")

			// Walletfunds
			await member1.sendTransaction({
				to: await multisigWallet.getAddress(),
				value: hre.ethers.parseEther("5"),
			})

			// Submit transaction (index 0)
			await multisigWallet.connect(member1).submitTransaction(await member2.getAddress(), amountToConfirm)

			return { multisigWallet, member1, member2, member3, amountToConfirm }
		}

		it("Should revert if caller is not an owner", async function () {
			const { multisigWallet } = await loadFixture(setupTransactionFixture)

			const [, , , outsider] = await hre.ethers.getSigners()

			await expect(multisigWallet.connect(outsider).confirmTransaction(0)).to.be.revertedWith("Not an owner")
		})

		it("Should record confirmation", async function () {
			const { multisigWallet, member1 } = await loadFixture(setupTransactionFixture)

			await multisigWallet.connect(member1).confirmTransaction(0)

			const confirmed = await multisigWallet.confirmations(0, await member1.getAddress())

			expect(confirmed).to.equal(true)
		})

		it("Should NOT execute before required confirmations", async function () {
			const { multisigWallet, member1, member2 } = await loadFixture(setupTransactionFixture)

			const balanceBefore = await hre.ethers.provider.getBalance(await member2.getAddress())

			await multisigWallet.connect(member1).confirmTransaction(0)

			const balanceAfter = await hre.ethers.provider.getBalance(await member2.getAddress())

			expect(balanceAfter).to.equal(balanceBefore)
		})

		it("Should execute after required confirmations", async function () {
			const { multisigWallet, member1, member2, amountToConfirm } = await loadFixture(setupTransactionFixture)

			const balanceBefore = await hre.ethers.provider.getBalance(await multisigWallet.getAddress())
			console.log(`balanceBefore: ${balanceBefore}`)
			await multisigWallet.connect(member1).confirmTransaction(0)
			await multisigWallet.connect(member2).confirmTransaction(0)

			const balanceAfter = await hre.ethers.provider.getBalance(await multisigWallet.getAddress())
			console.log(`balanceAfter: ${balanceAfter}`)

			expect(balanceAfter).to.equal(balanceBefore - amountToConfirm)
		})
	})
})
