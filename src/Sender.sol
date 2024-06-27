// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "forge-std/console.sol";

contract Token is ERC20{
    constructor() ERC20("",""){}

    function mint(uint amount) public{
        _mint(msg.sender,amount);
    }
}
contract TokenSender{
    using ECDSA for bytes32;

    mapping (bytes32 => bool) executed;
    function getHash(
        address sender,
        uint256 amount,
        address recepient,
        address tokenContract,
        uint nonce
    ) public pure returns(bytes32){
        return 
        keccak256(
            abi.encodePacked(sender,amount,recepient,tokenContract,nonce)
        );
    }

    function transfer(
        address sender,
        uint256 amount,
        address recepient,
        address tokenContract,
        uint nonce,
        bytes memory signature
    )public {
        bytes32 messageHash = getHash(sender,amount,recepient,tokenContract,nonce);
        bytes32 signedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        address signer = signedMessageHash.recover(signature);
        require(signer == sender, "Sender should sign");
        executed[signedMessageHash] = true;
         bool sent = ERC20(tokenContract).transferFrom(
            sender,
            recepient,
            amount
        );
        require(sent, "Transfer failed");
    }

}