pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'InitListDebot.sol';

contract ListAddingDebot is InitListDebot{

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping List debot";
        version = "0.2.0";
        publisher = "Nikita Ponomarev";
        key = "Shopping List manager";
        author = "Viltor";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Money Spent/Number of products purchased/Number of products not purchased)",
                    m_sumPurchases.total,
                    m_sumPurchases.numPaid,
                    m_sumPurchases.numNotPaid
            ),
            sep,
            [
                MenuItem("Show Shopping List","",tvm.functionId(showPurchase)),
                MenuItem("Delete Purchase","",tvm.functionId(DeletePurchase)),
                MenuItem("Make a Purchase","",tvm.functionId(MakePurchase))
            ]
        );
    }

function MakePurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(MakePurchase_), "Enter purchase number:", false);
        _menu();
    }

    function MakePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_purchaseId = uint32(num);
        Terminal.input(tvm.functionId(MakePurchase__), "Enter price: ", false);
    }

    function MakePurchase__(string value) public {
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).makePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, m_purchasePrice);
    }

    function showPurchase(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IntShoppingList(m_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchase_),
            onErrorId: 0
        }();
    }

    function showPurchase_( Purchase[] purchases ) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your purchases list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" count:{} price: {}  at {}", purchase.id, completed, purchase.name, purchase.count, purchase.price, purchase.timePurchase));
            }
        } else {
            Terminal.print(0, "Your purchase list is empty");
        }
        _menu();
    }


    function DeletePurchase(uint32 index) public {
        index = index;
        if (m_sumPurchases.numPaid + m_sumPurchases.numNotPaid > 0) {
            Terminal.input(tvm.functionId(DeletePurchase_), "Enter purcase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to delete");
            _menu();
        }
    }

    function DeletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
}