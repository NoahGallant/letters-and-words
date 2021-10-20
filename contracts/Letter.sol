// contracts/Letter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./StringUtils.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Letter is ERC721Enumerable, ReentrancyGuard, Ownable {

    constructor() ERC721("Letter", "LETTER") Ownable() {}

    function tokenURI(uint256 tokenId) override public pure returns (string memory) {
        string[3] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = getLetter(tokenId);

        parts[2] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Letter #', Strings.toString(tokenId), '", "id": "', Strings.toString(tokenId), '", "letter": "', getLetter(tokenId), '", "description": "Non-fungible letters. 100 of each.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 2601, "Letter not available");
        _safeMint(_msgSender(), tokenId);
    }
    
    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

}