// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SlotMachine {
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
        return block.timestamp / itemsCount;
    }

    function spin() external payable {
        address player = msg.sender;

        require(msg.value == cost, CostNotPaid());

        require(items.length != 0, EmptyInventory());

        while (true) {
            uint256 random = getRandom();
            Item memory item = items[random];
            if (item.collection == address(0)) continue;
            emptySlots.push(random);
            delete items[random];
            itemsCount--;
            // send nft
            emit Win(player, item.collection, item.id);
        }
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        require(tokenId <= type(uint96).max);
        if (emptySlots.length == 0) {
            items.push(Item({ collection: operator, id: uint96(tokenId) }));
        } else {
            uint256 slot = emptySlots[emptySlots.length - 1];
            emptySlots.pop();
            items[slot] = Item({ collection: operator, id: uint96(tokenId) });
        }

        itemsCount++;

        emit Put(operator, tokenId);

        // return selector
    }
}
