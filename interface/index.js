var Web3 = require('web3')

var web3 = new Web3(Web3.givenProvider || "ws://localhost:8545");
window.web3 = web3;

const LETTER_ADDR = '0x746F97D9BaF77A026AAF00040178bC12493c6Cd5' // Ropsten Letter Address
const WORD_ADDR = '0x6b81dBA50F7DEcD088dE06F588E9cBd1Afb9CED9' // Ropsten Word Address

const $ = (sel) => {
return document.querySelector(sel)
}

let letterAPI = require('./contracts/Letter.json').abi;
let wordAPI = require('./contracts/Word.json').abi;

let letter = new web3.eth.Contract(letterAPI, LETTER_ADDR)
let word = new web3.eth.Contract(wordAPI, WORD_ADDR)

window.letter = letter
window.word = word

async function getTokens(token, address) {
    let numTokens = await token.methods.balanceOf(address).call();
    let tokens = []
    for (let i = 0; i < numTokens; i++) {
        let tokenId = await token.methods.tokenOfOwnerByIndex(address, i).call();
        let tokenData = await token.methods.tokenURI(tokenId).call();
        tokens.push(JSON.parse(Buffer.from(tokenData.substring(29), 'base64')));
    }
    console.log(tokens)
    return tokens;
}

async function updateBalance() {
    let letters = await getTokens(letter, window.account);
    let words = await getTokens(word, window.account);
    let letterStrings = letters.map((v) => { return '<option value="'+ v.id +'">' + v.letter + ' ('+ v.name +')</option>' });
    let wordStrings = words.map((v) => { return '<option value="'+ v.id +'">' + v.word + '</option>' });
    $('#wallet').innerHTML = window.account;
    $('#letters').innerHTML = '<select id="letterSelect" name="letter">' + letterStrings.join('') + '</select';
    $('#words').innerHTML = '<select id="wordSelect" name="word">' + wordStrings.join('') + '</select>';
    $('#error').innerHTML = '';
    // $('#init').disabled = false
    $('#mint').disabled = false
    $('#create').disabled = false
    $('#pop').disabled = false
    $('#add').disabled = false
}

// Testing purposes only
async function initTokens(address) {
    let a = await letter.methods.claim(1).send({from: address, gas: 1000000});
    let b = await letter.methods.claim(2).send({from: address, gas: 1000000});
    let c = await letter.methods.claim(3).send({from: address, gas: 1000000});
    let d = await letter.methods.claim(4).send({from: address, gas: 1000000});

    await letter.methods.safeTransferFrom(address, word.options.address, 2).send({ from: address, gas: 1000000 });
    await letter.methods.setApprovalForAll(word.options.address, true).send({ from: address, gas: 1000000 });

    await updateBalance();
}

const ethEnabled = async () => {
    if (typeof window.ethereum !== 'undefined') {
      let accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      window.account = accounts[0];
      window.web3 = new Web3(window.ethereum);
      return true;
    }
    return false;
}

window.addEventListener('load', async () => {
    let enabled = await ethEnabled()
    if (enabled) { await updateBalance() }
})

$('#init')?.addEventListener('click', async () => {
    await initTokens(window.account)
})

$('#add').addEventListener('click', async () => {
    let letterId = $('#letterSelect').value;
    let wordId = $('#wordSelect').value;

    if (letterId !== '' && wordId !== '') {
        $('#error').innerHTML = 'Sending...'
        await letter.methods.approve(word.options.address, letterId).send({ from: window.account, gas: 1000000 });
        await word.methods.addLetter(letterId, wordId).send({ from: window.account, gas: 1000000 });
        await updateBalance();
    } else {
        $('#error').innerHTML = 'In order to add you must select a letter and word.'
    }
})

$('#pop').addEventListener('click', async () => {
    let wordId = $('#wordSelect').value;
    
    if (wordId !== '') {
        $('#error').innerHTML = 'Sending...'
        await word.methods.removeLetter(window.account, wordId).send({ from: window.account, gas: 1000000 });

        await updateBalance();
    } else {
        $('#error').innerHTML = 'In order to pop you must select a word.'
    }
})

$('#create').addEventListener('click', async () => {
    let letterId = $('#letterSelect').value;
    
    if (letterId !== '') {
        $('#error').innerHTML = 'Sending...'
        await letter.methods.safeTransferFrom(window.account, word.options.address, letterId).send({ from: window.account, gas: 1000000 });

        await updateBalance();
    } else {
        $('#error').innerHTML = 'In order to create a word you must select a letter.'
    }
})

$('#mint').addEventListener('click', async () => {
    let letterId = $('#newletters').selectedIndex + 1;
    
    for (let i = 0; i < 100; i++) {
        $('#error').innerHTML = 'Sending...'
        let minted = await letter.methods.exists(letterId + (26 * i)).call();
        if (!minted) {
            await letter.methods.claim(letterId + (26 * i)).send({ from: window.account, gas: 1000000 });

            await updateBalance();
            return;
        }
    }

    $('#error').innerHTML = 'All 100 of letter are already minted!';

})