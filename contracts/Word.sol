// contracts/String.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./StringUtils.sol";
import "./Letter.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Word is ERC721Enumerable, ERC721Holder, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // wordIds

    mapping(uint256 => uint256[]) words; // wordId => letterId[]
    IERC721 immutable letter; // Letter ERC721 interface
    
    constructor(address _letter) ERC721("Word", "WORD") Ownable() {
        letter = IERC721(_letter); // Get Letter Interface
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[7] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        
        parts[1] = getLetterOrEmpty(tokenId, 0);
        parts[2] = getLetterOrEmpty(tokenId, 1);
        parts[3] = getLetterOrEmpty(tokenId, 2);
        parts[4] = getLetterOrEmpty(tokenId, 3);
        parts[5] = getLetterOrEmpty(tokenId, 4);

        parts[6] = '</text></svg>';

        string memory str = string(abi.encodePacked(parts[1], parts[2], parts[3], parts[4], parts[5]));
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Word #', Strings.toString(tokenId), '", "id": "', Strings.toString(tokenId), '", "word": "', str, '", "description": "Non-fungible words. Composable from Letters.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    // Get Letter at index or empty string
    function getLetterOrEmpty(uint256 tokenId, uint index) private view returns (string memory) {
        uint len = words[tokenId].length;
        if (index > len - 1) {
            return '';
        } else {
            return getLetter(words[tokenId][index]);
        }
    }

    // Add letter to end of String (5 Letter limit)
    function addLetter(uint256 letterId, uint256 wordId) public nonReentrant {
        // require (letter.ownerOf(letterId) == msg.sender, 'Letter not owned by sender');
        // require (ownerOf(wordId) == msg.sender, 'Word not owned by sender');

        letter.transferFrom(_msgSender(), address(this), letterId);
        if (words[wordId].length == 5) {
            letter.safeTransferFrom(address(this), _msgSender(), words[wordId][0]); // Give back first letter if there are already 5 Letters in the Word
            words[wordId][0] = words[wordId][1];
            words[wordId][1] = words[wordId][2];
            words[wordId][2] = words[wordId][3];
            words[wordId][3] = words[wordId][4];
            words[wordId][4] = letterId;
        } else {
            words[wordId].push(letterId);
        }
    }

    // Pop Letter from end of Word
    function removeLetter(address _receiver, uint256 wordId) public {
        require (ownerOf(wordId) == _msgSender(), 'Word not owned by sender');

        uint lastIndex = words[wordId].length - 1;
        letter.safeTransferFrom(address(this), _receiver, words[wordId][lastIndex]); // Transfer Letter back
        
        words[wordId].pop();
        
        if (lastIndex == 0) {
            _burn(wordId);
        }
    }

    // Mint Word from Letter
    function letterToWord(address _sender, uint256 letterId) public {
        _tokenIds.increment();
        
        uint256 wordId = _tokenIds.current();
        _safeMint(_sender, wordId);
        words[wordId].push(letterId);
    }

    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata
    ) public virtual override returns (bytes4) {
        // require(_msgSender() == address(letter), 'Letter not received');
        letterToWord(_from, _tokenId);
        return this.onERC721Received.selector;
    }
}