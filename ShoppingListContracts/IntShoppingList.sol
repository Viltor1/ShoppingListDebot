pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

// This is class that describes you smart contract.
struct Purchase{
    uint32 id;
    string name;
    uint32 count;
    uint32 price;
    uint64 timePurchase;
    bool isDone;
    
}
struct SumPurchases {
    uint32 numPaid;
    uint32 numNotPaid;
    uint32 total;
}
interface IntShoppingList {
    function createPurchase(string title,uint32 count) external;
    function makePurchase(uint32 id, uint32 price) external;
    function deletePurchase(uint32 id) external;
    function getPurchases() external returns (Purchase[] purchases);
    function getSumPurchases() external returns (SumPurchases);
}

interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}
abstract contract AShoppingList {
   constructor(uint256 pubkey) public {}
}