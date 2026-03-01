const helpers = require("@nomicfoundation/hardhat-network-helpers")
import { ethers } from "hardhat"

const main = async () => {
	const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
	const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
	const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"

	const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621"

	await helpers.impersonateAccount(TokenHolder)
	const impersonatedSigner = await ethers.getSigner(TokenHolder)

	const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner)
	const DAI = await ethers.getContractAt("IERC20", DAIAddress, impersonatedSigner)
	const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner)

	const amountIn = ethers.parseUnits("1000", 6)
	const path = [USDC, DAI] //USDC/DAI
	const deadline = Math.floor(Date.now() / 1000) + 60 * 10

	await USDC.approve(ROUTER, amountIn)

	const txn = await ROUTER.swapExactTokensForTokens(amountIn, 0, path, impersonatedSigner.address, deadline)
	await txn.wait()

	console.log("Swap Exact Tokens → Tokens successful")
}

main().catch((err) => {
	console.log(err)
	process.exitCode = 1
})
