import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Wallet } from 'ethers';
describe('Existing', function () {
  let owner: Wallet;
  let user: Wallet;
  let challenge: any;
  let deployer: any;

  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    [owner, user] = await (ethers as any).getSigners();
    challenge = await (await ethers.getContractFactory('Existing'))
      .connect(owner)
      .deploy();

    // Get solver bytecode and abi
    deployer = await (await ethers.getContractFactory('ExistingSolverDeployer'))
      .connect(owner)
      .deploy();

    console.log('challenge', await challenge.getAddress());
    console.log('owner', await owner.getAddress());
    console.log('user', await user.getAddress());
    console.log('deployer', await deployer.getAddress());
  }

  beforeEach(async function () {
    await loadFixture(deployOneYearLockFixture);
  });

  it('solve', async function () {
    const challengeAddress = await challenge.getAddress();
    var salt = 0;
    console.log('Start to blasting solver address...');
    while (true) {
      const solverAddress = await deployer.calcSolverAddress.staticCall(
        salt,
        challengeAddress
      );
      if (await deployer.isSolverAddressValid.staticCall(solverAddress)) {
        console.log('salt', salt);
        console.log('solverAddress', solverAddress);
        break;
      }

      salt++;
    }
    await deployer.solve(salt, challengeAddress);
    expect(await challenge.isSolved()).to.be.true;
  }).timeout(1000000);
});
