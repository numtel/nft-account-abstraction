// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/AccountERC721.sol";
import "../contracts/Counter.sol";

contract AccountERC721Test is Test {
  AccountERC721 public collection;

  function setUp() public {
    collection = new AccountERC721("Test", "TEST", "http://localhost:3000/nft/1337/");
  }

  function testSimpleValidator(address secondUser, address thirdUser) public {
    require(secondUser != address(this) && secondUser != thirdUser);

    uint32 threshold = 10;
    MockValidator allow2ndUser = new MockValidator(secondUser);
    address[] memory validators = new address[](1);
    uint32[] memory scores = new uint32[](1);
    validators[0] = address(allow2ndUser);
    scores[0] = threshold;
    uint256 tokenId = collection.mint(validators, scores, threshold);
    ExternalAccount account = ExternalAccount(collection.tokenAccount(tokenId));

    Counter count = new Counter();

    address[] memory to = new address[](1);
    bytes[] memory data = new bytes[](1);
    to[0] = address(count);
    data[0] = abi.encodeWithSignature('increment()');
    account.execute(to, data, true);

    assertEq(count.number(), 1);

    vm.prank(secondUser);
    account.execute(to, data, true);
    assertEq(count.number(), 2);

    vm.prank(thirdUser);
    vm.expectRevert();
    account.execute(to, data, true);
    assertEq(count.number(), 2);

  }
}

contract MockValidator {
  address public allow;

  constructor(address _allow) {
    allow = _allow;
  }

  function validExecutor(uint256, address account) external view returns(bool) {
    return account == allow;
  }
}
