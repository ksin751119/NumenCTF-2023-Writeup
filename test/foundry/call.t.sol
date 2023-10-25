// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {IExistingStock} from "contracts/simplecall/contracts/IExistingStock.sol";
import {ExistingStockSolver} from "contracts/simplecall/contracts/callSolver.sol";

contract ExistingStockTest is Test {
    IExistingStock public challenge;
    ExistingStockSolver public solver;

    address public user;
    address public owner;

    function setUp() public {
        user = makeAddr("user");
        vm.deal(user, 200 ether);
        owner = makeAddr("owner");
        vm.prank(owner);

        challenge = IExistingStock(
            address(deployCode("call.sol:ExistingStock"))
        );
        solver = new ExistingStockSolver(address(challenge));
    }

    function testSolveExistingStock() public {
        vm.startPrank(user);
        solver.solve();
        vm.stopPrank();
        assertTrue(challenge.isSolved());
    }
}
