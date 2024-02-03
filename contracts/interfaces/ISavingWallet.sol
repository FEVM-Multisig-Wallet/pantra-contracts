// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

/**
 * @dev Define interface for SavingWallet
 */
interface IPantraSavingWallet {

    enum WithdrawalInterval {
        DAILY,
        WEEKLY,
        MONTHLY
    }

    function getBalance() external view returns (uint);
}