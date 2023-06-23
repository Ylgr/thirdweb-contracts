// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

// using for testing upgrade
import "./TokenERC20.sol";

contract TokenERC20v2 is TokenERC20
{
    mapping(address => uint256) private _blacklist;
    bytes32 internal constant BLACKLIST_ROLE = keccak256("BLACKLIST_ROLE");

    function initializeV2() public reinitializer(2) {
        _setupRole(BLACKLIST_ROLE, msg.sender);
    }

    function blacklist(address account) public {
        require(hasRole(BLACKLIST_ROLE, msg.sender), "TokenERC20v2: must have blacklist role to blacklist");
        _blacklist[account] = 1;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account] == 1;
    }

    function transfer(address recipient, uint256 amount) public override(ERC20Upgradeable, IERC20Upgradeable) returns (bool) {
        require(!isBlacklisted(msg.sender), "TokenERC20v2: sender is blacklisted");
        require(!isBlacklisted(recipient), "TokenERC20v2: recipient is blacklisted");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override(ERC20Upgradeable, IERC20Upgradeable) returns (bool) {
        require(!isBlacklisted(sender), "TokenERC20v2: sender is blacklisted");
        require(!isBlacklisted(recipient), "TokenERC20v2: recipient is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }
}
