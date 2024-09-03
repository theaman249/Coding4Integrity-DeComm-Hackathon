import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

import Types "../commons/Types";
import Product "Product";
import Transaction "Transaction";
import User "User";

//Actor
actor class Main() {
    stable var usersArray : [User.User] = [];
    stable var productsArray : [Product.Product] = [];
    stable var productIDNum : Nat = 0;
    stable var transactionsArray :[Transaction.Transaction]=[];
    stable var transactionIDNum:Nat = 0;

    var userBuffer = Buffer.fromArray<User.User>(usersArray);
    var productBuffer = Buffer.fromArray<Product.Product>(productsArray);
    var transactionBuffer=Buffer.fromArray<Transaction.Transaction>(transactionsArray);
    private var inCarts : Buffer.Buffer<(Text, Nat)> = Buffer.Buffer<(Text, Nat)>(0);

    public func addToCart(userID: Text, productID: Nat) : async Bool {
        if (not Buffer.contains(inCarts, (userID, productID), func(a: (Text, Nat), b: (Text, Nat)) : Bool { a.0 == b.0 and a.1 == b.1 })) {
            inCarts.add((userID, productID));
            Debug.print("Added to cart: " # debug_show((userID, productID)));
            return true;
        };
        Debug.print("Product already in cart: " # debug_show((userID, productID)));
        return false;
    };

    public func removeFromCart(userID: Text, productID: Nat) : async Bool {
        let beforeSize = inCarts.size();
        inCarts.filterEntries(func(index: Nat, item: (Text, Nat)) : Bool { 
            not (item.0 == userID and item.1 == productID)
        });
        let removed = inCarts.size() < beforeSize;
        Debug.print("Removed from cart: " # debug_show((userID, productID)) # " Success: " # debug_show(removed));
        return removed;
    };

    public func isInCart(userID: Text, productID: Nat) : async Bool {
        Buffer.contains(inCarts, (userID, productID), func(a: (Text, Nat), b: (Text, Nat)) : Bool { a.0 == b.0 and a.1 == b.1 })
    };

    public func getAllUserNames() : async [Text] {
        let namebuffer = Buffer.Buffer<Text>(0);
        for (index in usersArray.vals()) {
            let name = await index.getName();
            namebuffer.add(name);
        };
        return Buffer.toArray(namebuffer);
    };
    private func numberOfSplits(str : Text, delimiter : Text) : async Nat {
        var count : Nat = 0;
        for (c in str.chars()) {
            if (Text.equal(Text.fromChar(c), delimiter)) {
                count += 1;
            };
        };
        return count;
    };

    public func createUser<system>(name : Text) : async User.User {
        let fullNameSplits = await numberOfSplits(name, " ");
        if (fullNameSplits != 1) {
            let usernames = await getAllUserNames();
            for (username in usernames.vals()) {
                if (Text.equal(name, username)) {
                   return await loginUser(name);
                };
            };
        };
        splitCycles<system>();
        let user = await User.User(name, [], [], [], [], [{ currency = #eth; amount = 0 }, { currency = #btc; amount = 0 }, { currency = #icp; amount = 0 }, { currency = #usd; amount = 0 }, { currency = #gbp; amount = 0 }, { currency = #eur; amount = 0 }]);
        await updateUserArray(user);
        return user;
    };
    private func updateUserArray(user : User.User) : async () {
        userBuffer.add(user);
        usersArray := Buffer.toArray<User.User>(userBuffer);
    };

    public func loginUser(name : Text) : async User.User {
        for (index in usersArray.vals()) {
            if (Text.equal(name, await index.getName())) {
                return index;
            };
        };
        return await createUser(name);
    };

    public query func getAllUsers() : async [User.User] {
        return usersArray;
    };

    public func getAllUsersTypesFromObjectArray(userObjList : [User.User]) : async [Types.User] {
        let typeBuffer = Buffer.Buffer<Types.User>(0);
        for (user in userObjList.vals()) {
            typeBuffer.add(await (convertUserToType(user)));
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getAllUserTypes() : async [Types.User] {
        return await (getAllUsersTypesFromObjectArray(await getAllUsers()));
    };

    
    public func convertUserToType(user : User.User) : async Types.User {
        return {
            name = await user.getName();
            buyersCart = await user.getBuyersCart();
            sellersStock = await user.getSellersStock();
            purchases = await user.getPurchases();
            soldItems = await user.getSoldItems();
            wallet = await user.getWallet();
        };
    };


    public func createProduct<system>(user : Text, name : Text, category : Text, price : Types.Price, shortDesc : Text, longDesc : Text, isVisible : Bool, picture : Text) : async Product.Product {
        splitCycles<system>();
        var product = await Product.Product(user, name, category, price, shortDesc, longDesc, isVisible, picture, productIDNum);
        productIDNum := productIDNum + 1;
        await updateProductArray(product);
        return product;
    };

    private func updateProductArray(product : Product.Product) : async () {
        productBuffer.add(product);
        productsArray := Buffer.toArray<Product.Product>(productBuffer);
    };

    public query func getAllProducts() : async [Product.Product] {
        return productsArray;
    };

    public func getAllProductTypesFromObjectArray(productObjList : [Product.Product]) : async [Types.Product] {
        let typeBuffer = Buffer.Buffer<Types.Product>(0);
        for (product in productObjList.vals()) {
            typeBuffer.add(await (convertProductToType(product)));
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getAllProductTypes() : async [Types.Product] {
        return await (getAllProductTypesFromObjectArray(await getAllProducts()));
    };

    public func editProduct(productID : Nat, username: Text, newData:Types.Product) : async Bool{
        for(product in productsArray.vals()){
            let prod=await convertProductToType(product);
            if (prod.productID==productID and Text.equal(username, prod.sellerID)){
                if(newData.name.size()!=0) await product.setName(newData.name);
                if(newData.productLongDesc.size()!=0) await product.setLongDesc(newData.productLongDesc);
                if(newData.productShortDesc.size()!=0) await product.setShortDesc(newData.productShortDesc);
                if(newData.productCategory.size()!=0) await product.setCategory(newData.productCategory);
                if ((newData.isVisible and not prod.isVisible) or (not newData.isVisible and prod.isVisible)) await product.setIsVisible(newData.isVisible);
                if(prod.productPrice.currency!=newData.productPrice.currency or prod.productPrice.amount!=newData.productPrice.amount) await product.setPrice(newData.productPrice);
                return true;
            };
        };
        return false;
    };


    public func convertProductToType(product : Product.Product) : async Types.Product {
        return {
            sellerID = await product.getSellerID();
            name = await product.getName();
            productPrice = await product.getPrice();
            productShortDesc = await product.getShortDesc();
            productLongDesc = await product.getLongDesc();
            isSold = await product.getIsSold();
            isVisible = await product.getIsVisible();
            productID = await product.getProductID();
            productCategory = await product.getCategory();
            productPicture = await product.getPicture();
        };
    };


    public func createTransaction<system>(productID: Nat, buyerID: Text, paidPrice: Types.Price): async Transaction.Transaction {
        Cycles.add<system>(200000000000);
        var transaction = await Transaction.Transaction(transactionIDNum, productID, buyerID, paidPrice);
        transactionIDNum := transactionIDNum + 1;
        let _temp = await updateTransactionArray(transaction);
        return transaction;
    };

    private func updateTransactionArray(transaction: Transaction.Transaction): async () {
        transactionBuffer.add(transaction);
        transactionsArray := Buffer.toArray<Transaction.Transaction>(transactionBuffer);
    };

    public query func getAllTransactions(): async [Transaction.Transaction] {
        return transactionsArray;
    };

    public func convertTransactionToType(transaction : Transaction.Transaction) : async Types.Transaction {
        return {
            id = await transaction.getID();
            productID = await transaction.getProductID();
            buyerID = await transaction.getBuyerID();
            paidPrice = await transaction.getPaidPrice();
        };
    };

    public func getAllTransactionTypesFromObjectArray(transactionObjList: [Transaction.Transaction]): async [Types.Transaction] {
        let typeBuffer = Buffer.Buffer<Types.Transaction>(0);
        for (transaction in transactionObjList.vals()) {
            typeBuffer.add(await convertTransactionToType(transaction));
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getAllTransactionTypes(): async [Types.Transaction] {
        return await getAllTransactionTypesFromObjectArray(await getAllTransactions());
    };


    private func splitCycles<system>() {
        Cycles.add<system>(200000000000);
    };

    public func addToUserCart(userName: Text, product: Types.Product) : async Bool {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                if (await addToCart(userName, product.productID)) {
                    await user.addToCart(product);
                    Debug.print("Added to user cart: " # userName # ", Product: " # debug_show(product.productID));
                    return true;
                } else {
                    Debug.print("Failed to add to user cart: " # userName # ", Product: " # debug_show(product.productID));
                    return false;
                };
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return false;
            };
        };
    };

    public func removeFromUserCart(userName: Text, productID: Nat) : async Bool {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                if (await removeFromCart(userName, productID)) {
                    await user.removeFromCart(productID);
                    Debug.print("Removed from user cart: " # userName # ", Product: " # debug_show(productID));
                    return true;
                } else {
                    Debug.print("Failed to remove from user cart: " # userName # ", Product: " # debug_show(productID));
                    return false;
                };
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return false;
            };
        };
    };

    public func clearUserCart(userName: Text) : async Bool {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                let currentCart = await user.getBuyersCart();
                for (product in currentCart.vals()) {
                    ignore await removeFromCart(userName, product.productID);
                };
                await user.clearCart();
                Debug.print("Cleared user cart: " # userName);
                return true;
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return false;
            };
        };
    };

    public func getUserCartCount(userName : Text) : async Nat {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                let cart = await user.getBuyersCart();
                Debug.print("User cart count: " # userName # ", Count: " # debug_show(cart.size()));
                return cart.size();
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return 0;
            };
        };
    };

    public func getUserCartProductTypes(userName : Text) : async [Types.Product] {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                let cartProducts = await user.getBuyersCart();
                Debug.print("Retrieved user cart: " # userName # ", Items: " # debug_show(cartProducts.size()));
                return cartProducts;
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return [];
            };
        };
    };

    private func getUserCartProductTypesFromObjectArray(cartProducts : [Types.Product]) : async [Types.Product] {
        let typeBuffer = Buffer.Buffer<Types.Product>(0);
        for (product in cartProducts.vals()) {
            typeBuffer.add(product);
        };
        return Buffer.toArray(typeBuffer);
    };

    public func purchase(user : User.User, price : Types.Price, product : Product.Product) : async () {
        let sellerName = await product.getSellerID();
        let productPrice = await product.getPrice();
        let productID = await product.getProductID();
        let buyerID = await user.getName();
        for (index in usersArray.vals()) {
            let target = await index.getName();
            if (Text.equal(target, sellerName)) {
                let boolean = await user.takeFromWallet(productPrice);
                 if(boolean==#ok(())){
                let transaction= await createTransaction(productID,buyerID,price);
                let transactionType=await  convertTransactionToType(transaction);
                await index.addToWallet(productPrice);
                await index.addToSoldItems(transactionType);
                // await user.takeFromWallet(price);
                await user.addToPurchases(transactionType);
                }
            };
        };
    };

    public func clearDB(): async() {
        usersArray := [];
        productsArray := [];
        transactionsArray :=[];
        productIDNum := 0;
        transactionIDNum:=0;
        userBuffer := Buffer.fromArray<User.User>(usersArray);
        productBuffer:= Buffer.fromArray<Product.Product>(productsArray);
        transactionBuffer:=Buffer.fromArray<Transaction.Transaction>(transactionsArray); 
    };

    public func createTestEnv(): async(){
        await clearDB();
        let user1= await createUser("user1");
        let user2= await createUser("user2");
        let price1:Types.Price={
        currency = #usd;
        amount = 10;
        };
        let price2:Types.Price={
        currency = #usd;
        amount = 15;
        };
        let price3:Types.Price={
        currency = #usd;
        amount = 5;
        };

        let product1 = await createProduct("user1","prod1","cat1",price1,"short","long",true,"null");
        let _product2 = await createProduct("user2","prod2","cat1",price1,"short","long",true,"null");
        let product3 = await createProduct("user2","prod3","cat1",price2,"short","long",true,"null");
        let _product4 = await createProduct("user2","prod4","cat1",price3,"short","long",true,"null");
        
        await purchase(user2,price1,product1);
        await user2.addToWallet(price1);
        await purchase(user2,price1,product1);
        await user2.addToWallet(price1);
        await purchase(user2,price1,product1);
        await purchase(user1,price2,product3);
    };

    private func findUser(userName: Text) : async ?User.User {
        for (user in usersArray.vals()) {
            if (Text.equal(userName, await user.getName())) {
                return ?user;
            };
        };
        null
    };
};