# LETTERs and WORDs
NFT project for LETTERs and WORDs (ERC721). Inspired by [LOOT](https://lootproject.com) and [LootLoose](https://github.com/gakonst/lootloose).

## Configuration
Currently configured for Ropsten test network. An interface (`/interface`) to mint and call contract functions is accessible from [https://html-interface-noahg.vercel.app/](https://html-interface-noahg.vercel.app/). This interface requires MetaMask.

## Contract Documentation
This project is meant to demonstrate interchangable/composable [ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Enumerable) `LETTER` and `WORD` contracts.

### Letter.sol
`LETTER` is a simple enumerated [ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Enumerable) contract with two custom functions: `tokenURI` and `claim`. There exists 100 of each latin lowercase letter (a...z) available to claim.

***Ropsten address:*** `0x746F97D9BaF77A026AAF00040178bC12493c6Cd5`

#### tokenURI(uint256 tokenId)
The `tokenURI` function generates a Base64 JSON load with a unique `name` identifier, the corresponding `letter`, and a generated SVG `image` based on the LOOT contract.

#### claim(uint256 tokenId)
The `claim` function allows minting of `LETTER`s. `tokenId`s correspond to latin letters direction in a repeating fashion:

| tokenId | letter |
| --- | --- |
| 1 | a |
| 2 | b |
| ... | ... |
| 26 | z |
| 27 | a |
| 28 | b |
| ... | ... |
| 2599 | y |
| 2600 | z |

#### safeTransferFrom
Using the standard `safeTransferFrom` function to send a `LETTER` to the `WORD` contract address will mint and assign a new `WORD` to the sender containing the `LETTER`. See ***Word*** for more details on the contract.

### Word.sol
`WORD` is a more complicated enumerated [ERC721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Enumerable) and [ERC721Holder](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721Holder) which is composed of `LETTER`s. Each token can contain up to 5 `LETTER`s, with functions to `addLetter`, `popLetter` and convert a `letterToWord`.

***Ropsten address:*** `0x6b81dBA50F7DEcD088dE06F588E9cBd1Afb9CED9`

#### addLetter(uint256 letterId, uint256 wordId)
The `addLetter` function takes an existing `LETTER` NFT and creates a new `WORD` composed of only that letter. The function transfers the `LETTER` to the contract address, and adds it to a mapping of `WORD` token IDs to dynamic arrays of `LETTER` IDs. In order to limit on-chain data and gas costs the limit of letters per `WORD` is 5. Upon adding a 6th `LETTER` the first `LETTER` to be added is popped and transferred to the sender, and the new letter is added to the end of the `WORD`.

#### removeLetter(address _sender, uint256 wordId)
This function pops the last letter in the `WORD` and sends the token to the designated `_sender` address. If the `WORD` only contains 1 `LETTER` upon popping, the `WORD` token is burned.

#### letterToWord(uint256 letterId)
Similar to performing a `safeTransferFrom` of a `LETTER` to the `WORD` contract address, this function performs the same transfer and mints a new `WORD` owned by the sender.

## Interface Documentation
The interface in the repository is a simple Node.js application to allow for UI interaction with the `LETTER` and `WORD` contracts. The interface utilizes `web3.js` for contract interaction.

## Disclaimer
These contracts have not been audited nor extensively tested. It should not be deployed the the mainnet.

## TODO
* Write unit tests
* Extend interface