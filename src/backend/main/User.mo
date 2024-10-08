import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Types "../commons/Types";

actor class User(
    name : Text,
    email : Text,
    pHash : Nat32,
    walletID: Text,
    buyersCart : [Types.Product],
    sellersStock : [Types.Product],
    purchases : [Types.Transaction],
    soldItems : [Types.Transaction],
    wallet : [Types.Price],
    transfers: [Types.Transfer]
) {

    stable var userName : Text = name;
    stable var userEmail : Text = email;
    stable var userPHash : Nat32 = pHash;
    stable var userBuyersCart : [Types.Product] = buyersCart;
    stable var userSellersStock : [Types.Product] = sellersStock;
    stable var userPurchases : [Types.Transaction] = purchases;
    stable var userSoldItems : [Types.Transaction] = soldItems;
    stable var userTransfers: [Types.Transfer] = transfers;
    stable var userWallet : [Types.Price] = wallet;
    stable var userWalletID: Text = walletID;

    var buyersCartBuffer = Buffer.fromArray<Types.Product>(userBuyersCart);
    var sellersStockBuffer = Buffer.fromArray<Types.Product>(userSellersStock);
    var purchasesBuffer = Buffer.fromArray<Types.Transaction>(userPurchases);
    var soldItemsBuffer = Buffer.fromArray<Types.Transaction>(userSoldItems);
    var _walletBuffer = Buffer.fromArray<Types.Price>(userWallet);
    var transfersBuffer = Buffer.fromArray<Types.Transfer>(userTransfers);

    public query func getName() : async Text {
        return userName;
    };

    public query func getEmail() : async Text {
        return userEmail;
    };

    public query func getPHash() : async Nat32 {
        return userPHash;
    };

    public query func getWalletID(): async Text {
        return userWalletID;
    };
    
    public query func getSellersStock() : async [Types.Product] {
        return userSellersStock;
    };

    public query func getPurchases() : async [Types.Transaction] {
        return userPurchases;
    };

    public func addToSellersStock(product: Types.Product) : async () {
        sellersStockBuffer.add(product);
        userSellersStock := Buffer.toArray(sellersStockBuffer);
        Debug.print("Product added to seller's stock: " # debug_show(product.productID));
    };

    public shared(msg) func getCallerPrincipal() : async Principal {
        let caller : Principal = msg.caller;
        return caller;
    };

   public query func getSellerStockIDs() : async [Nat] {
        let sellerStockIDs = Array.map<Types.Product, Nat>(userSellersStock, func(product: Types.Product) : Nat {
            product.productID
        });

        return sellerStockIDs;
    };

    public query func getPurchasedStockIDs() : async [Nat] {
        let purchasedStockIDs = Array.map<Types.Transaction, Nat>(userPurchases, func(transaction: Types.Transaction) : Nat {
            transaction.productID
        });
        
        return purchasedStockIDs;
    };

    public query func getSoldItems() : async [Types.Transaction] {
        return userSoldItems;
    };

    public query func getTransfers(): async [Types.Transfer] {
        return userTransfers;
    };

    public query func getWallet() : async [Types.Price] {
        return userWallet;
    };

    public func setName(newName : Text) : async () {
        userName := newName;
    };

    public func setBuyersCart(newBuyersCart : [Types.Product]) : async () {
        userBuyersCart := newBuyersCart;
    };

    public func setSellersStock(newSellersStock : [Types.Product]) : async () {
        userSellersStock := newSellersStock;
    };

    public func setPurchases(newPurchases : [Types.Transaction]) : async () {
        userPurchases := newPurchases;
    };

    public func setSoldItems(newSoldItems : [Types.Transaction]) : async () {
        userSoldItems := newSoldItems;
    };

    public func setWallet(newWallet : [Types.Price]) : async () {
        userWallet := newWallet;
    };

    public  func  setTransfers(newTransfers : [Types.Transfer]) : async () {
        userTransfers := newTransfers;
    };

    public func listItem(product : Types.Product) : async () {
        sellersStockBuffer.add(product);
        await setSellersStock(Buffer.toArray(sellersStockBuffer));
    };

    public func addToPurchases(transaction : Types.Transaction) : async () {
        purchasesBuffer.add(transaction);
        await setPurchases(Buffer.toArray(purchasesBuffer));
    };

    public  func addToTransfer(transfer: Types.Transfer):async (){
        transfersBuffer.add(transfer);
        await setTransfers(Buffer.toArray(transfersBuffer)); //overload existing stable variable
    };

    public func addToSoldItems(transaction : Types.Transaction) : async () {
        soldItemsBuffer.add(transaction);
        await setSoldItems(Buffer.toArray(soldItemsBuffer));
    };

    public func addToWallet(price : Types.Price) : async () {
        var newWallet = Buffer.Buffer<Types.Price>(0);
        for (j in userWallet.vals()) {
            if (price.currency == j.currency) {
                var amount = j.amount +price.amount;
                let p : Types.Price = {
                    currency = price.currency;
                    amount = amount;
                };
                newWallet.add(p);
            } else {
                newWallet.add(j);
            };
        };
        await setWallet(Buffer.toArray(newWallet));
    };

    public func takeFromWallet(price : Types.Price) : async Result.Result<(), Text> {
        var newWallet = Buffer.Buffer<Types.Price>(0);
        for (j in userWallet.vals()) {
            if (price.currency == j.currency) {
                if (j.amount >= price.amount) {
                    var amount = j.amount : Nat - price.amount : Nat;
                    let p : Types.Price = {
                        currency = price.currency;
                        amount = amount;
                    };
                    newWallet.add(p);
                } else {
                    return #err("Insufficient funds");
                };
            } else {
                newWallet.add(j);
            };
        };
        await setWallet(Buffer.toArray(newWallet));
        #ok(());
    };

    public func addToCart(product : Types.Product) : async () {
        buyersCartBuffer.add(product);
        userBuyersCart := Buffer.toArray(buyersCartBuffer);
        Debug.print("User " # userName # " added product to cart: " # debug_show (product.productID));
    };

    public func removeFromCart(productID : Nat) : async () {
        let beforeSize = buyersCartBuffer.size();
        buyersCartBuffer.filterEntries(
            func(index : Nat, p : Types.Product) : Bool {
                p.productID != productID;
            }
        );
        userBuyersCart := Buffer.toArray(buyersCartBuffer);
        let removed = buyersCartBuffer.size() < beforeSize;
        Debug.print("User " # userName # " removed product from cart: " # debug_show (productID) # " Success: " # debug_show (removed));
    };

    public func clearCart() : async () {
        buyersCartBuffer.clear();
        userBuyersCart := [];
        Debug.print("User " # userName # " cleared cart");
    };

    public query func getBuyersCart() : async [Types.Product] {
        Debug.print("Retrieved cart for user " # userName # ": " # debug_show (userBuyersCart.size()) # " items");
        return userBuyersCart;
    };
};
