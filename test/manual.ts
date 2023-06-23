import { ethers } from "hardhat";
import { expect } from "chai";
import {TokenERC20, TokenERC20v2} from "typechain";
describe("manual", function () {
  let tokenERC20: TokenERC20
  let tokenERC20v2: TokenERC20v2


  before(async () => {
    const [deployer] = await ethers.getSigners();
    const TokenERC20 = await ethers.getContractFactory("TokenERC20");
    tokenERC20 = await TokenERC20.deploy();
    await tokenERC20.deployed();
  });

  describe("upgrade to v2 and can use blacklist", () => {
    it("should upgrade to v2", async () => {
      const TokenERC20v2 = await ethers.getContractFactory("TokenERC20v2");
      tokenERC20v2 = await upgrades.upgradeProxy(tokenERC20.address, TokenERC20v2);
      await tokenERC20v2.deployed();
      expect(await tokenERC20v2.version()).to.equal("v2");
    });
  })

});
