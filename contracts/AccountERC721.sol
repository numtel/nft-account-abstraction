// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC4906.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC165.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "./IValidator.sol";

contract AccountERC721 is ERC721Enumerable, IERC4906 {
  uint256 public tokenCount;
  string public urlPrefix;

  mapping(uint256 => address) public tokenAccount;
  mapping(uint256 => address[]) public tokenValidators;
  mapping(uint256 => uint32[]) public tokenValidatorScores;
  mapping(uint256 => uint32) public tokenValidatorThreshold;

  constructor(
    string memory name,
    string memory symbol,
    string memory _urlPrefix
  ) ERC721(name, symbol) {
    urlPrefix = _urlPrefix;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
    return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    _requireOwned(tokenId);
    return string(abi.encodePacked(urlPrefix, Strings.toHexString(address(this)), '/', Strings.toString(tokenId)));
  }

  function mint(address[] memory validators, uint32[] memory scores, uint32 threshold) external returns (uint256) {
    require(validators.length == scores.length);

    uint256 newTokenId = ++tokenCount;
    _mint(msg.sender, newTokenId);

    ExternalAccount newAccount = new ExternalAccount(newTokenId);
    tokenAccount[newTokenId] = address(newAccount);
    tokenValidators[newTokenId] = validators;
    tokenValidatorScores[newTokenId] = scores;
    tokenValidatorThreshold[newTokenId] = threshold;

    return newTokenId;
  }

  function validExecutor(uint256 tokenId, address account) external view returns(bool) {
    uint32 score;
    for(uint256 i = 0; i < tokenValidators[tokenId].length; i++) {
      if(IValidator(tokenValidators[tokenId][i]).validExecutor(tokenId, account)) {
        score += tokenValidatorScores[tokenId][i];
      }
    }
    return score >= tokenValidatorThreshold[tokenId];
  }


}

contract ExternalAccount {
  AccountERC721 public creator;
  uint256 public tokenId;

  event TxSent(address to, bytes data, bool success, bytes returned);

  constructor(uint256 _tokenId) {
    creator = AccountERC721(msg.sender);
    tokenId = _tokenId;
  }

  // TODO function to send eth balance

  function execute(address[] memory to, bytes[] memory data, bool requireAll) external {
    require(msg.sender == creator.ownerOf(tokenId)
      || creator.validExecutor(tokenId, msg.sender));
    require(to.length == data.length);
    for(uint d = 0; d < data.length; d++) {
      (bool success, bytes memory returned) = to[d].call(data[d]);
      emit TxSent(to[d], data[d], success, returned);
      if(requireAll) require(success, string(abi.encodePacked('Failed item #', Strings.toString(d))));
    }
  }
}
