import hre, { ethers } from "hardhat";
import { Contract } from "ethers";
import WalletFactory from "../artifacts/contracts/SavingFactory.sol/PantraSavingWalletFactory.json";

async function test() {
  const network = hre.network.name;
  const [deployer, _] = await ethers.getSigners();
  const savingFactory = new Contract("0x86001e93Be963522Ad8f58A067801A9d0f3af037", WalletFactory.abi, deployer);
  await savingFactory.createWallet(0);
  const depositAmount = ethers.parseEther("0.01");
  await savingFactory.deposit({value: depositAmount});
  console.log(deployer.address)
}
test().catch((error) => console.log(error));