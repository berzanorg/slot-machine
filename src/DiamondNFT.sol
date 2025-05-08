// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DiamondNFT is ERC721("Diamond", "DIAMOND") {
    constructor() {
        for (uint256 i = 0; i < 10; i++) {
            super._mint(msg.sender, i);
        }
    }
}
