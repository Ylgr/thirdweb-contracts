// ██████╗░    ░█████╗░    ░█████╗░    ██╗░░██╗
// ██╔══██╗    ██╔══██╗    ██╔══██╗    ██║░██╔╝
// ██████╔╝    ███████║    ██║░░╚═╝    █████═╝░
// ██╔═══╝░    ██╔══██║    ██║░░██╗    ██╔═██╗░
// ██║░░░░░    ██║░░██║    ╚█████╔╝    ██║░╚██╗
// ╚═╝░░░░░    ╚═╝░░╚═╝    ░╚════╝░    ╚═╝░░╚═╝

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract ControlCenter is AccessControl {

  bytes32 public constant PROTOCOL_ADMIN = keccak256("PROTOCOL_ADMIN");

  address public treasury;
  bool public protocolInitialized;
  
  string public constant PACK = "PACK";
  string public constant RNG = "RNG";
  string public constant HANDLER = "HANDLER";
  string public constant MARKET = "MARKET";
  string public constant ASSET_SAFE = "ASSET_SAFE";

  mapping(bytes32 => address) public modules;
  mapping(string => bytes32) public moduleId;

  event ModuleAdded(string moduleName, bytes32 moduleId, address module);
  event ModuleUpdated(string moduleName, bytes32 moduleId, address module);
  event ModuleDeleted(string moduleName, bytes32 moduleId, address module);

  modifier onlyProtocolAdmin() {
    require(hasRole(PROTOCOL_ADMIN, msg.sender), "Only protocol admins can call this function.");
    _;
  }

  constructor(address _treasury) {
    treasury = _treasury;

    _setupRole(PROTOCOL_ADMIN, msg.sender);
    _setRoleAdmin(PROTOCOL_ADMIN, PROTOCOL_ADMIN);
  }

  /// @dev Iniializes the ERC 1155 module of the pack protocol.
  function initPackProtocol(
    address _pack,
    address _handler,
    address _market,
    address _rng,
    address _assetSafe
  ) external onlyProtocolAdmin {
    require(!protocolInitialized, "The protocol has already been initialized.");

    addModule(PACK, _pack);
    addModule(HANDLER, _handler);
    addModule(MARKET, _market);
    addModule(RNG, _rng);
    addModule(ASSET_SAFE, _assetSafe);
  }

  /// @dev Lets protocol admin add a module to the pack protocol.
  function addModule(string memory _moduleName, address _moduleAddress) public onlyProtocolAdmin {
    require(modules[moduleId[_moduleName]] == address(0), "A module with this name already exists.");
    bytes32 id = keccak256(bytes(_moduleName));

    moduleId[_moduleName] = id;
    modules[id] = _moduleAddress;

    emit ModuleAdded(_moduleName, id, _moduleAddress);
  }

  /// @dev Lets protocol admin change address of a module of the pack protocol.
  function changeModuleAddress(string calldata _moduleName, address _newModuleAddress) external onlyProtocolAdmin {
    require(modules[moduleId[_moduleName]] != address(0), "The given module does not exist.");

    bytes32 id = keccak256(bytes(_moduleName));
    modules[id] = _newModuleAddress;

    emit ModuleUpdated(_moduleName, id, _newModuleAddress);
  }

  /// @dev Lets protocol admin delete a module of the pack protocol.
  function deleteModule(string calldata _moduleName) external onlyProtocolAdmin {
    require(modules[moduleId[_moduleName]] != address(0), "The given module does not exist.");

    bytes32 id = keccak256(bytes(_moduleName));

    delete modules[id];
    delete moduleId[_moduleName];

    emit ModuleDeleted(_moduleName, id, address(0));
  }

  /// @dev Returns a module of the pack protocol.
  function getModule(string memory _moduleName) public view returns (address) {
    return modules[moduleId[_moduleName]];
  }

  /// @notice Pauses all activity in the ERC1155 part of the protocol.
  function pausePackERC1155() external onlyProtocolAdmin {
    ERC1155PresetMinterPauser(
      getModule(PACK)
    ).pause();
  }

  /// @notice Grants a role in the protocol's ERC1155 module.
  function grantRoleERC1155(bytes32 _role, address _receiver) external onlyProtocolAdmin {
    ERC1155PresetMinterPauser(
      getModule(PACK)
    ).grantRole(_role, _receiver);
  }

  /// @notice Revokes a role in the protocol's ERC1155 module.
  function revokeRoleERC1155(bytes32 _role, address _subject) external onlyProtocolAdmin {
    ERC1155PresetMinterPauser(
      getModule(PACK)
    ).revokeRole(_role, _subject);
  }

  /// @notice Grants the `PROTOCOL_ADMIN` role to `_newAdmin`.
  function makeProtocolAdmin(address _newAdmin) external onlyProtocolAdmin {
    grantRole(PROTOCOL_ADMIN, _newAdmin);
  } 

  /// @notice Revokes the `PROTOCOL_ADMIN` role from `_revokeFrom`
  function removeProtocolAdmin(address _revokeFrom) external onlyProtocolAdmin {
    revokeRole(PROTOCOL_ADMIN, _revokeFrom);
  }

  /// @notice Lets protocol admin change the treaury address.
  function changeTreasury(address _newTreasury) external onlyProtocolAdmin {
    treasury = _newTreasury;
  }
}