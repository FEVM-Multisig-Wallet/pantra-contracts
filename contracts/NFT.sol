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

    function _generateSVG(address wallet, uint256 id) public view returns (string memory svg) {
        uint balance = IPantraSavingWallet(wallet).getBalance();
        string memory balanceToString = convertWEIToEtherString(balance);
        NFTSVG.SVGParams memory param = NFTSVG.SVGParams({
            walletAddress: addressToString(wallet),
            userAddress: addressToString(_ownerOf(id)),
            nftSymbol: symbol(),
            nftName: name(),
            walletBalance: balanceToString
        });
        svg = NFTSVG.generateSVG(param);
    }

    function _generateSVGNotMinted() public view returns (string memory svg)  {
        NFTSVG.SVGParams memory param = NFTSVG.SVGParams({
            walletAddress: '',
            userAddress: '',
            nftSymbol: symbol(),
            nftName: name(),
            walletBalance: ''
        });
        svg = NFTSVG.generateSVG(param);
    }

    function mintItem(address walletAddress, address owner) public onlyAdmin {
        bool minted = _ownerOf(uint256(uint160(walletAddress))) != address(0);
        if (!minted) {
            _safeMint(owner, uint256(uint160(walletAddress)));
        }
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        bool minted = _ownerOf(id) != address(0);

        address walletAddress = address(uint160(id));
        string memory _name = name();
        string memory _desc = name();
        string memory svg = "";
        if (minted) {
            svg = _generateSVG(walletAddress, id);
        } else {
            svg = _generateSVGNotMinted();
        }
        string memory image = Base64.encode(bytes(svg));
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            _name, 
                            '","description":"',
                            _desc,
                            '","image":"',
                            'data:image/svg+xml;base64,',
                            image,
                            '"}'
                        )
                    )
                )
            )
        );
        //return svg;
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
    
    /// @dev converts address to a string
    function addressToString(address _address) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

