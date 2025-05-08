// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SlotMachine is IERC721Receiver {
    event Win(address indexed player, address indexed collection, uint256 id);
    event Put(address indexed collection, uint256 id);

    error EmptyInventory();
    error CostNotPaid();

    uint256 itemsCount;

    uint256 public constant cost = 10 ether;

    uint256[] emptySlots;

    Item[] items;

    struct Item {
        address collection;
        uint96 id;
    }

    function getRandom() internal view returns (uint256) {
        return block.timestamp % itemsCount;
    }

    function spin() external payable {
        require(msg.value == cost, CostNotPaid());

        require(itemsCount != 0, EmptyInventory());

        for (uint256 i = 0;; i++) {
            uint256 random = getRandom(); // get another random number when that item is already given
            Item memory item = items[random];
            if (item.collection == address(0)) continue;
            emptySlots.push(random);
            delete items[random];
            IERC721(item.collection).transferFrom(address(this), msg.sender, uint256(item.id));

            emit Win(msg.sender, item.collection, item.id);

            itemsCount--;

            break;
        }
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata)
        external
        returns (bytes4)
    {
        require(tokenId <= type(uint96).max);
        if (emptySlots.length == 0) {
            items.push(Item({ collection: msg.sender, id: uint96(tokenId) }));
        } else {
            uint256 slot = emptySlots[emptySlots.length - 1];
            emptySlots.pop();
            items[slot] = Item({ collection: msg.sender, id: uint96(tokenId) });
        }

        itemsCount++;

        emit Put(msg.sender, tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }
}
