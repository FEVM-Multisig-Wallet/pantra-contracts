//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interfaces/ISavingWallet.sol";
import "./NFTSVG.sol";

contract PantraSmartWalletNFT is ERC721 {

    address public admin;

    constructor(address _admin) ERC721("PantraSmartWalletNFT", "PNFT") {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not permitted");
        _;
    }

    function generateSVG(address wallet) public view returns (string memory svg) {
        uint balance = IPantraSavingWallet(wallet).getBalance();
        string memory balanceToString = convertWEIToEtherString(balance);
        NFTSVG.SVGParams memory param = NFTSVG.SVGParams({
            walletAddress: '0x5adaf849e40B5b1303507299D3d06a4663D3A8b8',
            userAddress: '0x78E3a0Eb75016521E460D8efd62e08390B9736e7',
            nftSymbol: symbol(),
            nftName: name(),
            walletBalance: balanceToString,
            color0: '#2b0fff',
            color1: '#f09ad4',
            color2: '#766abc',
            color3: '',
            x1: '600',
            y1: '300',
            x2: '600',
            y2: '200',
            x3: '500',
            y3: '150'
        });
        svg = NFTSVG.generateSVG(param);
    }

    function mintItem(address walletAddress, address owner) public onlyAdmin {
        _safeMint(owner, uint256(uint160(walletAddress)));
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        bool minted = _ownerOf(id) != address(0);

        address walletAddress = address(uint160(id));
        string memory walletBalance = "";
        if (minted) {
        
            IPantraSavingWallet wallet = IPantraSavingWallet(walletAddress);
            walletBalance = string(
                abi.encodePacked(
                    unicode'<text x="20" y="305">Balance',
                    convertWEIToEtherString(wallet.getBalance()),
                    "</text>"
                )
            );
        }

        return walletBalance;
    }
    
    /// @dev converts wei to ether string in two decimal places
    function convertWEIToEtherString(uint256 weiValue) public pure returns (string memory) {
        uint256 finneyValue = weiValue / 1e15;
        return string(
            abi.encodePacked(
                Strings.toString(finneyValue / 1000),
                ".",
                Strings.toString((finneyValue % 1000)/100),
                Strings.toString(((finneyValue % 1000) % 100) / 10)
            )
        );
    }
}

