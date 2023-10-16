// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SmartCounter} from "contracts/counter/contracts/Counter.sol";

contract SmartCounterTest is Test {
    SmartCounter public challenge;
    address public owner;
    address public user;

    function setUp() external {
        owner = makeAddr("owner");
        user = makeAddr("user");
        vm.prank(owner);
        challenge = new SmartCounter(owner);
    }

    function testSolveSmartCounter() external {
        // PUSH20 $USER_ADDR
        // PUSH0
        // SSTORE
        bytes memory code1 = hex"73";
        bytes memory code2 = abi.encodePacked(user);
        bytes memory code3 = hex"5f55";
        bytes memory code = abi.encodePacked(code1, code2, code3);

        vm.startPrank(user);
        challenge.create(code);
        challenge.A_delegateccall(hex"");
        vm.stopPrank();
        assertTrue(challenge.isSolved());
    }
}
