// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Check} from "contracts/reca2/Re.sol";
import {CheckSolver} from "contracts/reca2/ReSolver.sol";

contract CheckTest is Test {
    Check public challenge;
    CheckSolver public solver;

    address public user;
    address public owner;
    address public yourAddress;

    function setUp() public {
        user = makeAddr("user");
        vm.deal(user, 200 ether);
        owner = makeAddr("owner");
        vm.prank(owner);
        challenge = new Check();
        solver = new CheckSolver(address(challenge.lenderPool()));
    }

    function testSolveCheck() public {
        vm.startPrank(user);
        solver.solve();
        vm.stopPrank();
        assertTrue(challenge.isSolved());
    }
}
