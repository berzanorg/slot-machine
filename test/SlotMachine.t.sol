// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SlotMachine } from "../src/SlotMachine.sol";
import { Test, console } from "forge-std/Test.sol";

contract SlotMachineTest is Test {
    SlotMachine public slotMachine;
    address public player;
    uint256 public cost;

    function setUp() public {
        slotMachine = new SlotMachine();
        player = makeAddr("player");
        cost = slotMachine.cost();
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

    function test_Topup() public { }

    function test_TopupAndSpin() public { }
    function test_TopupAndSpinAndTopup() public { }
}
