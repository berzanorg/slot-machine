// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NormalNFT is ERC721("Normal", "NORMAL") {
    constructor() {
        for (uint256 i = 0; i < 20; i++) {
            super._mint(msg.sender, i);
        }
    }
}
