pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "IntShoppingList.sol";

contract ShoppingList is IntShoppingList{
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - task not found
     */

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;

    mapping(uint32 => Purchase) m_purchase;

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function createPurchase(string name, uint32 count) public onlyOwner override {
        tvm.accept();
        m_count++;
        m_purchase[m_count] = Purchase(m_count, name, count, 0, now, false);
    }

    function makePurchase(uint32 id, uint32 price) public onlyOwner override {
        optional(Purchase) purchase = m_purchase.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Purchase thisPurchase = purchase.get();
        thisPurchase.isDone = true;
        thisPurchase.price = price;
        m_purchase[id] = thisPurchase;
    }

    function deletePurchase(uint32 id) public onlyOwner override {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }

    //
    // Get methods
    //

    function getPurchases() public override  returns (Purchase[] purchases) {
        string name;
        uint32 count;
        uint32 price;
        uint64 timePurchase;
        bool isDone;

        for((uint32 id, Purchase purchase) : m_purchase) {
            name = purchase.name;
            count = purchase.count;
            timePurchase = purchase.timePurchase;
            isDone = purchase.isDone;
            price = purchase.price;
            purchases.push(Purchase(id, name, count, price, timePurchase, isDone));
       }
    }

    function getSumPurchases() public override returns (SumPurchases sumPurchases) {
        uint32 numPaid;
        uint32 numNotPaid;
        uint32 total;

        for((, Purchase purchase) : m_purchase) {
            if  (purchase.isDone) {
                numPaid ++;
                total += purchase.price;
            } else {
                numNotPaid ++;
            }
        }
        sumPurchases = SumPurchases( numPaid, numNotPaid , total );
    }
    }

