const Letter = artifacts.require('Letter');
const Word = artifacts.require('Word')

module.exports = async function (deployer) {
  await deployer.deploy(Letter);
  let letter = await Letter.deployed()
  await deployer.deploy(Word, letter.address)
};