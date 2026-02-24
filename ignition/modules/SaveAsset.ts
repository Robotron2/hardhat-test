import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

const SaveAssetModule = buildModule("SaveAssetModule", (m) => {
	const saveAsset = m.contract("SaveAsset")

	return { saveAsset }
})

export default SaveAssetModule
