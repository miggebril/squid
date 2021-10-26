pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract CardBase  {

    struct PlayerCard {
		uint64 creationTime;

        // address for active player
		address currentAddress;

        // number of games won 
        uint128 currentWinCount;

		// address for next player, when current player is no longer active
		address nextAddress;
	}

    PlayerCard[] cards;

    uint64 public constant MAX_CARDS = 5000;

    mapping (uint256 => address) public cardIdToOwner;
	mapping (address => uint256[]) public ownerToCardIds;

    mapping (address => uint256) ownerToCardCount;

    // events
    event Transfer(address from, address to, uint256 tokenID);
    event NewCard(address owner, uint256 cardID);

    function greet() public view returns (string memory) {
        return "greet";
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return cardIdToOwner[tokenId] != address(0);
    }

    function _transfer(address _from, address _to, uint256 _cardID) internal {
        console.log("Start transfer");

        ownerToCardCount[_to]++;
        
        console.log("Assign ID %d to %s", _cardID, _to);

        cardIdToOwner[_cardID] = _to;

        if (_from != address(0)) {
            ownerToCardCount[_from]--;
        }

        console.log("Emit transfer");
        emit Transfer(_from, _to, _cardID);
    }

    function _createCard(address _owner) internal returns (uint256) {
        console.log("Create owner address %s", _owner);
        
        PlayerCard memory _card = PlayerCard({
            creationTime: uint64(block.timestamp),
            currentAddress: _owner,
            currentWinCount: 0,
            nextAddress: address(0)
        });

        cards.push(_card);
        uint256 newCard = cards.length;
        console.log("New Card ID: ", newCard);

        require(newCard <= MAX_CARDS, "Exceeds minting capacity");

        emit NewCard(_owner, newCard);

        _transfer(address(0), _owner, newCard);
        return newCard;
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _createCard(to);
    }
}