// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;
import {Test} from "lib/forge-std/src/Test.sol";
import {Token, TokenSender} from '../src/Sender.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TestSender is Test{
    using ECDSA for bytes32;
    Token public tokenContract;
    TokenSender public senderContract;
    // anvil test account
    uint256 privKeyOfUserAddress = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address userAddress = vm.addr(privKeyOfUserAddress);
    address relayerAddress = vm.addr(2);
    address recipientAddress = vm.addr(3);

    function setUp() public {
        tokenContract = new Token();
        senderContract = new TokenSender();
        vm.startPrank(userAddress);
        tokenContract.mint(1000 ether);
        tokenContract.approve(
            address(senderContract),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        vm.stopPrank();
    }
    
    function testSender() public {
        bytes32 hashedMessage = senderContract.getHash(userAddress, 10 ether, recipientAddress, address(tokenContract));
        bytes32 messageHashSigned = MessageHashUtils.toEthSignedMessageHash(hashedMessage);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privKeyOfUserAddress,
            messageHashSigned
        );

        bytes memory signedSignature = abi.encodePacked(r, s, v);
        vm.prank(relayerAddress);
        senderContract.transfer(userAddress, 10 ether, recipientAddress, address(tokenContract), signedSignature);
        uint userBalance = tokenContract.balanceOf(userAddress);
        uint recipientBalance = tokenContract.balanceOf(recipientAddress);
        assertLt(userBalance, 10000 ether);
        assertGt(recipientBalance, 0 ether);



    }
        
}