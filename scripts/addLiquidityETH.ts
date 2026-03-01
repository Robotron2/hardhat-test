const helpers = require("@nomicfoundation/hardhat-network-helpers")
import { ethers } from "hardhat"

const main = async () => {
	const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
	const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
	const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621"

	await helpers.impersonateAccount(TokenHolder)
	const impersonatedSigner = await ethers.getSigner(TokenHolder)

	const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner)
	const router = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner)

	const amountToken = ethers.parseUnits("1000", 6)
	const deadline = Math.floor(Date.now() / 1000) + 600

	await USDC.approve(UNIRouter, amountToken)

	await router.addLiquidityETH(USDC, amountToken, 0, 0, impersonatedSigner.address, deadline, {
		value: ethers.parseEther("1"),
	})

	console.log("Add Liquidity ETH successful")
}

main().catch((err) => {
	console.log(err)
	process.exitCode = 1
})
