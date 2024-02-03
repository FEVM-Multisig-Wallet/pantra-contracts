// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/utils/Strings.sol';
import '@uniswap/v3-core/contracts/libraries/BitMath.sol';
import '@openzeppelin/contracts/utils/Base64.sol';

/// @title NFTSVG
/// @notice Provides a function for generating an SVG associated with a PantraWallet NFT
library NFTSVG {
    using Strings for uint256;

    struct SVGParams {
        string walletAddress;
        string userAddress;
        string nftSymbol;
        string nftName;
        string walletBalance;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory svg) {
        return
            string(
                abi.encodePacked(
                    generateSVGDefs(),
                    generateSVGBorderText(
                        params.walletAddress,
                        params.userAddress,
                        params.nftSymbol,
                        params.nftName
                    ),
                    generateSVGCardMantle(params.walletBalance),
                    '</svg>'
                )
            );
                
    }
    
    function generateSVGDefs() private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg"',
                " xmlns:xlink='http://www.w3.org/1999/xlink'>",
                '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="#111" />',
                '<path d="M20 140C20 73.7258 73.7258 20 140 20H150C216.274 20 270 73.7258 270 140V252H20V140Z" fill="url(#paint0_angular_1681_99)"/>'

                '<defs>',
                    '<path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V460 A28 28 0 0 1 250 488 H40 A28 28 0 0 1 12 460 V40 A28 28 0 0 1 40 12 z" />',

                    '<radialGradient id="paint0_angular_1681_99" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(197.989 70.1923) rotate(43.8986) scale(94.908 192.313)">',
                        '<stop stop-color="#7CCE7F"/>',
                        '<stop offset="0.192244" stop-color="#FF6D4D"/>',
                        '<stop offset="0.317708" stop-color="#84E9FF"/>',
                        '<stop offset="0.510417" stop-color="#918FF4"/>',
                    '</radialGradient>',
                '</defs>'
            )
        );
    }

    function generateSVGBorderText(
        string memory walletAddress,
        string memory userAddress,
        string memory nftSymbol,
        string memory nftName
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<text text-rendering="optimizeSpeed">',
                '<textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                walletAddress,
                unicode' • ',
                nftName,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                '</textPath> <textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                userAddress,
                unicode' • ',
                nftSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath>',
                '<textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                walletAddress,
                unicode' • ',
                nftName,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s"',
                ' repeatCount="indefinite" /></textPath><textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                userAddress,
                unicode' • ',
                nftSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath></text>'
            )
        );
    }

    function generateSVGCardMantle(
        string memory walletBalance
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<g mask="url(#fade-symbol)"><rect fill="none" x="0px" y="0px" width="290px" height="200px" /> <text y="294px" x="24px" fill="white" font-family="\'Courier New\', monospace" font-weight="200" font-size="36px">',
                'Pantra'
                '</text><text y="320px" x="24px" fill="white" font-family="\'Courier New\', monospace" font-weight="70" font-size="14px">',
                'Powered by Lightlink',
                '</text></g>',

                // Wallet balance
                '<text y="437px" x="24px" fill="white" font-family="\'Courier New\', monospace" font-weight="200" font-size="30px">',
                walletBalance,
                ' ETH',
                '</text>',
                '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" />'
            )
        );
    }
}