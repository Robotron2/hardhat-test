import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import * as dotenv from "dotenv"

dotenv.config()

const config: HardhatUserConfig = {
	solidity: "0.8.30",
	networks: {
		lisk: {
			url: process.env.LISK_URL!,
			accounts: [process.env.PRIVATE_KEY!],
		},
	},
}

export default config
