// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { DiamondNFT } from "../src/DiamondNFT.sol";
import { NormalNFT } from "../src/NormalNFT.sol";
import { SlotMachine } from "../src/SlotMachine.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Test, console } from "forge-std/Test.sol";

contract SlotMachineTest is Test {
    SlotMachine public slotMachine;
    address public player;
    address public deployer;
    uint256 public cost;
    DiamondNFT public diamondNFT;
    NormalNFT public normalNFT;

    function setUp() public {
        slotMachine = new SlotMachine();
        cost = slotMachine.cost();
        player = makeAddr("player");
        deployer = makeAddr("deployer");

        vm.prank(deployer);
        diamondNFT = new DiamondNFT();

        vm.prank(deployer);
        normalNFT = new NormalNFT();
    }

    function test_RevertWhenCostNotPaid() public {
        vm.startPrank(player);
        vm.deal(player, cost);

        vm.expectRevert(SlotMachine.CostNotPaid.selector);

        slotMachine.spin{ value: cost - 1 }();
    }

    function test_RevertWhenSpinWithNoInventory() public {
        vm.startPrank(player);
        vm.deal(player, cost);

        vm.expectRevert(SlotMachine.EmptyInventory.selector);

        slotMachine.spin{ value: cost }();
    }

    function test_Put() public {
        vm.startPrank(deployer);
        for (uint256 i = 0; i < 10; i++) {
            vm.expectEmit(true, true, true, true);
            emit IERC721.Transfer(deployer, address(slotMachine), i);
            diamondNFT.safeTransferFrom(deployer, address(slotMachine), i);
        }

        for (uint256 i = 0; i < 20; i++) {
            vm.expectEmit(true, true, true, true);
            emit IERC721.Transfer(deployer, address(slotMachine), i);
            normalNFT.safeTransferFrom(deployer, address(slotMachine), i);
        }
    }

    function test_PutAndSpinUntilEmptyInventory() public {
        vm.startPrank(deployer);
        for (uint256 i = 0; i < 10; i++) {
            diamondNFT.safeTransferFrom(deployer, address(slotMachine), i);
        }

        for (uint256 i = 0; i < 20; i++) {
            normalNFT.safeTransferFrom(deployer, address(slotMachine), i);
        }

        vm.startPrank(player);
        vm.deal(player, cost * 31);

        for (uint256 i = 0; i < 30; i++) {
            vm.warp(i);
            slotMachine.spin{ value: cost }();
        }
    }
}
