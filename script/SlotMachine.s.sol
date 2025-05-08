// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SlotMachine } from "../src/SlotMachine.sol";
import { Script, console } from "forge-std/Script.sol";

contract SlotMachineScript is Script {
    SlotMachine public slotMachine;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        slotMachine = new SlotMachine();

        vm.stopBroadcast();
    }
}
