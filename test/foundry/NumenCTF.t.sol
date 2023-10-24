// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Numen} from "contracts/littlemoney/contracts/NumenCTF.sol";

contract NumenTest is Test {
    event SendFlag(address);

    Numen public challenge;

    address public user;
    address public owner;
    address public yourAddress;

    function setUp() public {
        user = makeAddr("user");
        vm.deal(user, 200 ether);
        owner = makeAddr("owner");
        vm.prank(owner);
        challenge = new Numen();
    }

    function testSolveNumen() public {
        vm.startPrank(user);
        yourAddress = deploy(_generateBytecode());

        // In script, you could use --with-gas-price price
        // https://learnblockchain.cn/docs/foundry/i18n/zh//reference/forge/forge-script.html
        // 0x1f5 - 0x22a = 0xffffffcb
        // Please use the 'erever' command line tool to find the instructions.
        // For detailed NumenCTF opcode information, refer to 'contracts/littlemoney/erever_disassemble'.
        vm.txGasPrice(0xffffffcb);
        vm.expectEmit(true, true, true, true);
        emit SendFlag(user);
        challenge.execute(yourAddress);
        vm.stopPrank();
    }

    function deploy(bytes memory _code) public payable returns (address addr) {
        assembly {
            // create(v, p, n)
            // v = amount of ETH to send
            // p = pointer in memory to start of code
            // n = size of code
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        // return address 0 on error
        require(addr != address(0), "deploy failed");
    }

    function _generateBytecode() internal returns (bytes memory) {
        // Deploy code
        // PUSH32 0x435f523a60205260405ffd000000000000000000000000000000000000000000
        // PUSH1 0x00
        // MSTORE
        // PUSH1 0x0b // code length in memory
        // PUSH1 0x00 // code start in memory
        // RETURN

        // Execution code (0x435f52604460205260405ffd)
        // NUMBER
        // PUSH0
        // MSTORE
        // GASPRICE
        // PUSH1 0x20
        // MSTORE
        // PUSH1 0x40
        // PUSH0
        // REVERT

        return
            hex"7f435f523a60205260405ffd000000000000000000000000000000000000000000600052600b6000f3";
    }
}
