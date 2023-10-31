// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IValidator {
  function validExecutor(uint256 tokenId, address account) external view returns(bool);
}
