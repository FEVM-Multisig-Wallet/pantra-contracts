import { expect } from "chai";
import { Contract } from "ethers";
import hre, { ethers } from "hardhat";
import { PantraSavingWalletFactory } from "../typechain-types";
import SavingWallet from "../artifacts/contracts/Saving.sol/PantraSavingWallet.json";
import { PantraSmartWalletNFT } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { writeFile } from "fs";
const helpers = require("@nomicfoundation/hardhat-network-helpers");


describe("Pantra Savings Contract and Savings Factory Test", function () {
  let savingFactory: PantraSavingWalletFactory;
  let savingWallet:   Contract;
  let nftCollection: PantraSmartWalletNFT;
  let deployer: HardhatEthersSigner;
  let feeCollector: HardhatEthersSigner;
  let walletUser: HardhatEthersSigner;
  const depositAmount = ethers.parseEther("10");
  const withdrawalAmount = ethers.parseEther("0.5");

  const createHTML = (svg: string) => {
    return `
    <html>
      <head>
        <title>SVG</title>
      </head>
      <body>
        <img src='${svg}'/>
      </body>
    </html>
    `;
  };
  

  beforeEach(async function () {
    // Deploy the savings factory
    const [ _deployer, _feeCollector, _walletUser ] = await ethers.getSigners();
    savingFactory = await ethers.deployContract(
      "PantraSavingWalletFactory",
      [_feeCollector.address]
    );
    nftCollection = await ethers.deployContract(
      "PantraSmartWalletNFT",
      [await savingFactory.getAddress()]
    );
    await savingFactory.setWalletNFTCollection(await nftCollection.getAddress())
    await savingFactory.connect(_walletUser).createWallet(1);
    await savingFactory.connect(_walletUser).deposit({value: depositAmount});
    const savingWalletAddress = await savingFactory.connect(_walletUser).getWallet();
    savingWallet = new Contract(savingWalletAddress, SavingWallet.abi, _deployer);
    deployer = _deployer;
    feeCollector = _feeCollector;
    walletUser = _walletUser;
  });

  it("Test Saving Wallet and Factory Infos", async () => {
    expect(await savingFactory.feeCollector()).to.equal(feeCollector.address);
    expect(await savingWallet.withdrawalInterval()).to.equal(1);
    expect(await savingWallet.feeCollector()).to.equal(feeCollector.address);
    expect(await savingWallet.owner()).to.equal(walletUser.address);
    expect(await savingWallet.lastWithdrawalTime()).to.equal(0);
    expect(await savingWallet.getBalance()).to.equal(depositAmount);
    expect(await savingFactory.wallets(walletUser)).to.equal(await savingWallet.getAddress());
  });

  it("Test Minted NFT", async () => {
    expect((await nftCollection.balanceOf(walletUser.address)).toString()).to.equal("1");
    expect(await nftCollection.name()).to.equal("PantraSmartWalletNFT");
    expect(await nftCollection.symbol()).to.equal("PNFT");
    expect(await nftCollection.admin()).to.equal(await savingFactory.getAddress());
    await (expect(nftCollection.mintItem(await savingWallet.getAddress(), walletUser.address)).to.be.revertedWith("Not permitted"));
  });

  it("Test Withdrawal", async () => {
    await savingFactory.connect(walletUser).withdraw(withdrawalAmount);
    expect(await savingFactory.connect(walletUser).getWalletBalance()).to.equal(depositAmount - withdrawalAmount);
    expect(await savingWallet.lastWithdrawalTime()).to.gt(0);
    let initialCollectorBalance = await ethers.provider.getBalance(feeCollector.address);
    await savingFactory.connect(walletUser).withdraw(withdrawalAmount);
    let finalCollectorBalance = await ethers.provider.getBalance(feeCollector.address);
    expect(parseFloat(ethers.formatEther(finalCollectorBalance)) - parseFloat(ethers.formatEther(initialCollectorBalance))).gte(0.0049);
    await helpers.time.increase(24*60*60*7);
    initialCollectorBalance = await ethers.provider.getBalance(feeCollector.address);
    await savingFactory.connect(walletUser).withdraw(withdrawalAmount);
    finalCollectorBalance = await ethers.provider.getBalance(feeCollector.address);
    expect(parseFloat(ethers.formatEther(finalCollectorBalance)) - parseFloat(ethers.formatEther(initialCollectorBalance))).lt(0.0000001);
  });

  it("Test Change Withdrawal Interval", async () => {
    await savingFactory.connect(walletUser).withdraw(withdrawalAmount);
    // can only change interval once a new withdrawal window is opened
    await (expect(savingFactory.connect(walletUser).setWithdrawalInterval(0)).to.be.revertedWith("Next Withdrawal Window not opened"))
    // shift the time forward to open the window
    await helpers.time.increase(24*60*60*7);
    // the window is open so the withdrawal interval can be changed
    await savingFactory.connect(walletUser).setWithdrawalInterval(0);
    expect(await savingWallet.withdrawalInterval()).to.equal(0)
    
  })

  it("Test Reverting checks for Factory methods [Savings Wallet not Found]", async () => {
    await (expect(savingFactory.setWithdrawalInterval(0)).to.be.revertedWith("Savings Wallet not found"));
    await (expect(savingFactory.getWallet()).to.be.revertedWith("Savings Wallet not found"));
    await (expect(savingFactory.deposit({value: depositAmount})).to.be.revertedWith("Savings Wallet not found"));
    await (expect(savingFactory.withdraw(withdrawalAmount)).to.be.revertedWith("Savings Wallet not found"));
    await (expect(savingFactory.getWalletBalance()).to.be.revertedWith("Savings Wallet not found"));
  })

  it("Multiple Desposit test", async () => {
    const [ _deployer, _feeCollector, _walletUser ] = await ethers.getSigners();
    await savingFactory.connect(_walletUser).deposit({value: depositAmount});
    await savingFactory.connect(_walletUser).deposit({value: depositAmount});
    await savingFactory.connect(_walletUser).deposit({value: depositAmount});
  })

  it("Test NFT SVG", async () => {
    const resp = await nftCollection.tokenURI(
      BigInt(await savingWallet.getAddress())
    );

    const html = createHTML(resp);

    writeFile("./test.html", html, function (err) {
      if (err) {
        return console.log(err);
      }
      console.log("The file was saved!");
    });
  });
})