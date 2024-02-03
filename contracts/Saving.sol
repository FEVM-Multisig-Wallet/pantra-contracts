// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract PantraSavingWallet {
    enum WithdrawalInterval {
        DAILY,
        WEEKLY,
        MONTHLY
    }

    WithdrawalInterval public withdrawalInterval;
    uint public lastWithdrawalTime;
    uint public earlyWithdrawalFee = 1; // 1% fee on early withdrawals
    address payable public owner;
    address payable public feeCollector; // early withdrawal fee collector

    constructor(
        WithdrawalInterval interval,
        address _owner,
        address _feeCollector
    ) {
        owner = payable(_owner);
        feeCollector = payable(_feeCollector);
        withdrawalInterval = interval;
    }

    modifier onlyOwner(address _owner) {
        require(_owner == owner, "Not Permitted");
        _;
    }

    function withdrawalWindowOpen() internal view returns (bool) {
        (bool success, uint interval) = Math.trySub(block.timestamp, lastWithdrawalTime);
        require(success);
        if (withdrawalInterval == WithdrawalInterval.DAILY) {
            return (interval >= 1 days);
        } else if (withdrawalInterval == WithdrawalInterval.WEEKLY) {
            return (interval >= 7 days);
        } else {
            return (interval >= 30 days);
        }
    }

    modifier canChangeInterval() {
        require(withdrawalWindowOpen(), "Next Withdrawal Window not opened");
        _;
    }

    function setWithdrawalInterval(
        address _owner,
        WithdrawalInterval interval
    ) public onlyOwner(_owner) canChangeInterval {
        withdrawalInterval = interval;
    }

    function deposit() public payable {}

    function withdraw(address _owner, uint amount) public onlyOwner(_owner) {
        bool windowIsOpened = withdrawalWindowOpen();
        if (windowIsOpened) {
            (bool success, ) = owner.call{value: amount}("");
            require(success, "Withdrawal Failed");
        } else {
            uint fee = Math.mulDiv(amount, earlyWithdrawalFee, 100);
            (bool status, uint remainder) = Math.trySub(amount, fee);
            require(status);
            (bool success1, ) = owner.call{value: remainder}("");
            (bool success2, ) = feeCollector.call{value: fee}("");
            require(success1 && success2, "Withdrawal Failed");
        }
        lastWithdrawalTime = block.timestamp;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
