// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

/**
 * @dev Define interface for PantraNFT
 */
interface IPantraSmartWalletNFT {

    function mintItem(address walletAddress, address owner) external;
}