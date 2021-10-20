// scripts/index.js
// Test run for Localhost

module.exports = async function main (callback) {
    try {
      let accounts = await web3.eth.getAccounts();
      const Letter = artifacts.require('Letter');
      const letter = await Letter.deployed();
      
      const Word = artifacts.require('Word');
      const word = await Word.deployed();

      await letter.claim(1);
      await letter.claim(2);
      await letter.claim(3);
      await letter.claim(4);

      console.log(word.address);

      await letter.safeTransferFrom(accounts[0], word.address, 1);
      let owner = await letter.ownerOf(1);
      console.log(owner);

      await letter.setApprovalForAll(word.address, true);

      await word.addLetter(2, 1);
      await word.addLetter(3, 1);

      let w = await word.tokenURI(1);
      
      console.log('My word currently is', JSON.parse(Buffer.from(w.substring(29), 'base64')).word);

      await word.removeLetter(accounts[0], 1);
      w = await word.tokenURI(1);
      console.log('My word currently is', JSON.parse(Buffer.from(w.substring(29), 'base64')).word);

      await word.addLetter(4, 1);
      w = await word.tokenURI(1);
      console.log('My word currently is', JSON.parse(Buffer.from(w.substring(29), 'base64')).word);

      callback(0);
    } catch (error) {
      console.error(error);
      callback(1);
    }
  };