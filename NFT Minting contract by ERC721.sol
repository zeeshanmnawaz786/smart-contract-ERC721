// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AstroNa is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    
    string public baseURI;
    uint public whiteListLimit = 40;
    uint public publicLimit = 50;
    uint public plateformLimit = 10;
    uint public totalMintLimit =100;
    uint public maxWhitelistedLimit =5;
    uint public numberOfWhitelisted;
    bool public publicMinting ;
    bool public whitelistMinting =true;

     struct nftInfo{
        string name;
        string metadataHash;
    }

    event whitelistEvent(string name, string hash); 
    event publicEvent(string name, string hash); 
    event plateformEvent(string name, string hash); 
    event publicSaleActive(address owner, string message);
    event publicSaleUnActive(address owner, string message);
    event plateformAdd(address owner, address plateformAdmin);
    event whiteListedAdd(address owner, address whitelistAdd);
    event whiteListedRemove(address owner, address whitelistRemove);

    mapping ( uint => nftInfo) public nftData;
    mapping ( address => bool ) public whitelistedMintMapping;
    mapping ( address => bool ) public plateformMintMapping;

    constructor() ERC721("AstroNa", "ASN") {
        baseURI = "https://gateway.pinata.cloud/ipfs/";
    }
        
        modifier requireConditions() {
        require(totalSupply() < totalMintLimit, "Not mint any NFT due to limit Exceeed");
        require(balanceOf(msg.sender) != 5, "your limit exceed");
        _;
    }
   
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /*
    * @dev whiteListMint is used to mint NFT by whitelisted address to contract.
    *
    * Requirement:
    * - This function can only whitelisted address of contract
    *
    @param _tokenID - _name - _metadataHash
    */


    function whiteListMint( uint _tokenID, string memory _name, string memory _metadataHash) public requireConditions {
        require( whitelistedMintMapping[msg.sender] == true, "you can,t mint NFT");
        require(whiteListLimit !=0, "whitelist Minting limit exceed");
        nftData[_tokenID] = nftInfo(_name, _metadataHash);
        whiteListLimit -= 1;
        _safeMint(msg.sender, _tokenID);
        emit whitelistEvent(_name, _metadataHash);
    }

    /*
    * @dev publicMint is used to mint NFT by public address to contract.
    *
    * Requirement:
    * - This function can call any address of contract
    *
    * @param _tokenID - _name - _metadataHash
    */

    function publicMint( uint _tokenID, string memory _name, string memory _metadataHash) public requireConditions {
        require(publicLimit !=0, "public Minting Limit Exceed");
        require(publicMinting == true,"Public minting not started yet");
        nftData[_tokenID] = nftInfo(_name, _metadataHash);
        _safeMint(msg.sender, _tokenID);
        emit publicEvent(_name, _metadataHash);
    }

    /*
    * @dev plateformMint is used to mint NFT by plateform address to contract.
    *
    * Requirement:
    * - This function can only plateform address of contract
    *
    * @param _tokenID - _name - _metadataHash
    */

    function plateformMint( uint _tokenID, string memory _name, string memory _metadataHash) public requireConditions {
        require(plateformLimit !=0, "plateform Minting limit exceed");
        nftData[_tokenID] = nftInfo(_name, _metadataHash);
        _safeMint(msg.sender, _tokenID);
        emit plateformEvent(_name, _metadataHash);
    }

    /*
    * @dev activePublicSale is used to active the public sale and stop
    * whiteListed lImit of NFT to contract.
    *
    * Requirement:
    * - This function can only by the owner address of contract
    */

    function activePublicSale() public onlyOwner{
        whitelistMinting = false;
        publicMinting = true;
        publicLimit += whiteListLimit;
        whiteListLimit -= whiteListLimit;
        emit publicSaleActive(msg.sender, "active public sale");
    }

    /*
    * @dev pubSaleUnActive is used to unactive the public sale to contract
    *
    * Requirement:
    * - This function can only by the owner address of contract
    */

    function unActivePublicSale() public onlyOwner{
        publicMinting = false;
        emit publicSaleUnActive(msg.sender, "un active public sale");
    }

    /*
    * @dev addUserplateform is used to add the plateform address to contract
    *
    * Requirement:
    * - This function can only by the owner address of contract
    *
    * @param _address
    */

    function addUserplateform(address _address) public onlyOwner{
        require( !plateformMintMapping[_address], "address already register in plateform Minyting");
        plateformMintMapping[_address] = true;
        emit plateformAdd(msg.sender, _address);
    }

    /*
    * @dev addUserWhitelist is used to whiteList the address to contract
    *
    * Requirement:
    * - This function can only by the owner address of contract
    *
    * @param _address
    */

    function addUserWhitelist(address _address) public onlyOwner{
        require(whitelistMinting ==true,"WhiteList minting stopped");
        require( !whitelistedMintMapping[_address], "address already whitelisted");
        require( numberOfWhitelisted < maxWhitelistedLimit, "whitelist limit exceedd");
        whitelistedMintMapping[_address] = true;
        numberOfWhitelisted ++;
        emit whiteListedAdd(msg.sender, _address);
    }

    /*
    * @dev removeWhitelist is used to remove the whitelisted address to contract
    *
    * Requirement:
    * - This function can only by the owner address of contract
    *
    * @param _address
    */

    function removeWhitelist(address _address) public onlyOwner{
        require( whitelistedMintMapping[_address], "Address is not a whitelist");
        whitelistedMintMapping[_address] = false;
        numberOfWhitelisted --;
        emit whiteListedRemove(msg.sender, _address);

    }



    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


     function URIUpdate(string memory _baseURI) public{
        require(plateformMintMapping[msg.sender] == true, "Yo can,t change BaseURI");
        baseURI = _baseURI;
    }
    
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, nftData[tokenId].metadataHash));
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
