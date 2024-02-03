// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Saving.sol";
import "./interfaces/INFT.sol";

contract PantraSavingWalletFactory {

    address public feeCollector;
    address public admin;
    IPantraSmartWalletNFT public walletNFT;
    mapping(address => address) public wallets;
    mapping(address => bool) public minted;

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
        admin = msg.sender;
    }

    modifier walletExists() {
        require(wallets[msg.sender] != address(0), "Savings Wallet not found");
        _;
    }

    modifier walletNotExists() {
        require(wallets[msg.sender] == address(0), "Savings Wallet Exists for Address");
        _;
    }

    function setWalletNFTCollection(address _address) public {
        require(msg.sender == admin, "Not Permitted");
        walletNFT = IPantraSmartWalletNFT(_address);
    }

    function createWallet(PantraSavingWallet.WithdrawalInterval interval) public walletNotExists {
        PantraSavingWallet wallet = new PantraSavingWallet(interval, msg.sender, feeCollector);
        wallets[msg.sender] = address(wallet);
    }

    function getWallet() public walletExists view returns (address) {
        return wallets[msg.sender];
    }

    function deposit() public walletExists payable {
        address payable walletAddress = payable(wallets[msg.sender]);
        (bool success, ) = walletAddress.call{value: msg.value}(
            abi.encodeWithSignature("deposit()")
        );
        require(success, "Deposit Failed");
        if (!minted[msg.sender]) {
            walletNFT.mintItem(walletAddress, msg.sender);
        }
    }

    function withdraw(uint amount) public walletExists {
        address walletAddress = wallets[msg.sender];
        PantraSavingWallet(walletAddress).withdraw(msg.sender, amount);
    }

    function setWithdrawalInterval(PantraSavingWallet.WithdrawalInterval interval) public walletExists {
        address walletAddress = wallets[msg.sender];
        PantraSavingWallet(walletAddress).setWithdrawalInterval(msg.sender, interval);
    }

    function getWalletBalance() public walletExists view returns (uint) {
        address walletAddress = wallets[msg.sender];
        return walletAddress.balance;
    }
}