import hre, { ethers } from "hardhat";

async function deploy() {
  const network = hre.network.name;
  const [deployer, _] = await ethers.getSigners();
  const savingFactory = await ethers.deployContract("PantraSavingWalletFactory", [deployer.address]);
  await savingFactory.waitForDeployment();
  const nftCollection = await ethers.deployContract("PantraSmartWalletNFT", [await savingFactory.getAddress()]);
  await nftCollection.waitForDeployment();
  await savingFactory.setWalletNFTCollection(await nftCollection.getAddress());

  console.log(`Saving Wallet Factory Deployed At ${savingFactory.target} For ${network}`);
  console.log(`Pantra NFT Collection Deployed At ${nftCollection.target} For ${network}`);
  console.log(`Deployer Address: ${deployer.address}`)
}
deploy().catch((error) => console.log(error));
