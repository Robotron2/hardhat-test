import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { expect } from "chai"
import hre from "hardhat"

describe("Todo", function () {
	// We define a fixture to reuse the same setup in every test.
	// We use loadFixture to run this setup once, snapshot that state,
	// and reset Hardhat Network to that snapshot in every test.
	async function deployTodo() {
		// Contracts are deployed using the first signer/account by default
		const [owner, otherAccount] = await hre.ethers.getSigners()

		const Todo = await hre.ethers.getContractFactory("Todo")
		const todo = await Todo.deploy()

		let title = "Do laundry"
		await todo.createTask(title)

		return { todo, title, owner, otherAccount }
	}

	describe("Deployment", function () {
		it("Should create a todo", async function () {
			const { todo, title } = await loadFixture(deployTodo)

			let allTasks = await todo.getAllTasks()

			expect(allTasks.length).to.equal(1)
			expect(allTasks[0].title).to.equal(title)
		})

		it("Should mark task complete", async function () {
			const { todo } = await loadFixture(deployTodo)

			await todo.markComplete(1)
			let allTasks = await todo.getAllTasks()

			expect(allTasks[0].isComplete).to.equal(true)
			expect(allTasks[0].timeCompleted).not.equal(0)
		})

		it("Should delete task", async function () {
			const { todo } = await loadFixture(deployTodo)

			await todo.deleteTask(1)
			let allTasks = await todo.getAllTasks()

			expect(allTasks.length).equal(0)
		})
	})
})
