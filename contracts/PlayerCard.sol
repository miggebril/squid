pragma solidity ^0.8.9;
import "./CardBase.sol";
import "hardhat/console.sol";

contract PlayerCard is CardBase {
    string public constant name = "SquidCards";
	string public constant symbol = "SQD";

    mapping(uint256 => string) private tokenURIs;

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "TokenID not found for URI query");

        return string(abi.encodePacked(tokenURIs[tokenId]));
    }

    function requireCardExists(uint256 cardID) public view {
		require (cardID < totalSupply(), "CardID exceeds supply");
	}

    function totalSupply() public view returns (uint) {
		return MAX_CARDS - cards.length;
	}

    function balanceOf(address _owner) public view returns (uint256 count) {
		return ownerToCardCount[_owner];
	}

    function transfer(address _to, uint256 _cardId) external {
		// Prevent transfer to 0x00 address
		require(_to != address(0), "Transferring to no address");

		// Prevent transfers to contract
		require(_to != address(this), "Can't transfer to contract");

		// Prevent transfers if card _cardId is not owned by the sender
		require(_owns(msg.sender, _cardId), "Only owner can transfer");

		// Reassign ownership and emit transfer event
		_transfer(msg.sender, _to, _cardId);
	}

    function createCard() public returns (uint256) {
		require(msg.sender != address(this), "Can't transfer to contract");

		// Create the card
		uint256 cardID = _createCard(msg.sender);

		return cardID;
	}

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        console.log("Lookup owner of ID: ", _tokenId);
		owner = cardIdToOwner[_tokenId];
        console.log("Found owner: ", owner);
		require (owner != address(0), "Owner must have valid address");
        return owner;
	}

    function _owns(address _claimant, uint256 _cardID) internal view returns (bool) {
		return cardIdToOwner[_cardID] == _claimant;
	}

    function _setTokenURI(uint256 tokenId, string memory tokenUri) internal {
        require(_exists(tokenId), "URI set for nonexistent token ID");
        tokenURIs[tokenId] = tokenUri;
    }

    // EXPENSIVE: restrict calls to outside of contract
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
		uint256 tokenCount = balanceOf(_owner);

		if (tokenCount == 0) { // No tokens, return an empty array
			return new uint256[](0);
		} else {
			uint256[] memory result = new uint256[](tokenCount);
			uint256 totalTokens = totalSupply();
			uint256 resultIndex = 0;

			uint256 cardID;
			for (cardID = 1; cardID <= totalTokens; cardID++) {
				if (cardIdToOwner[cardID] == _owner) {
					result[resultIndex] = cardID;
					resultIndex++;
				}
			}

			return result;
		}
	}
}