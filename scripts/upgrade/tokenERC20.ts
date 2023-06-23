import {ethers, upgrades} from "hardhat";
import * as process from "process";

async function main() {
  const TokenERC20v2 = await ethers.getContractFactory("TokenERC20v2");
  const tokenERC20v2 = await upgrades.upgradeProxy(process.env.TOKEN_ERC20_ADDRESS || '', TokenERC20v2);
  await tokenERC20v2.deployed();
}

main().then(() => process.exit(0)).catch((error) => {
  console.error(error);
  process.exit(1);
})
