import { ethers } from "hardhat"

const main = async () => {
	const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
	const WETHAddress = "0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2"
	const ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"

	const [impersonatedSigner] = await ethers.getSigners()
	const router = await ethers.getContractAt("IUniswapV2Router", ROUTER, impersonatedSigner)

	const DAI = await ethers.getContractAt("IERC20", DAIAddress, impersonatedSigner)
	const WETH = await ethers.getContractAt("IERC20", WETHAddress, impersonatedSigner)

	const path = [WETH, DAI]
	const deadline = Math.floor(Date.now() / 1000) + 600

	await router.swapETHForExactTokens(ethers.parseUnits("1000", 18), path, impersonatedSigner.address, deadline, {
		value: ethers.parseEther("5"),
	})

	console.log("Swap ETH For Exact Tokens successful")
}

main().catch((err) => {
	console.log(err)
	process.exitCode = 1
})
