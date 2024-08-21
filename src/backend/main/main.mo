import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";

import Types "../commons/Types";
import Product "Product";
//Import not used Ali* - Hamad
import Transaction "Transaction";
import User "User";

//Actor
actor class Main() {
    stable var usersArray : [User.User] = [];
    stable var productsArray : [Product.Product] = [];
    stable var productIDNum : Nat = 0;
    stable var transactionsArray :[Transaction.Transaction]=[];
    stable var transactionIDNum:Nat =0;

    var userBuffer = Buffer.fromArray<User.User>(usersArray);
    var productBuffer = Buffer.fromArray<Product.Product>(productsArray);
    var transactionBuffer=Buffer.fromArray<Transaction.Transaction>(transactionsArray);

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
            var flag : Bool = false;
            let usernames = await getAllUserNames();
            for (username in usernames.vals()) {
                if (Text.equal(name, username)) {
                    flag := true;
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

    // public func editProduct(productID : Nat) : async (){

    // };

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

    public func purchase(user : User.User, price : Types.Price, product : Product.Product) : async () {
        let sellerName = await product.getSellerID();
        for (index in usersArray.vals()) {
            let target = await user.getName();
            if (Text.equal(target, sellerName)) {
                await index.addToWallet(price);
            };
        };
    };

    private func convertProductToType(product : Product.Product) : async Types.Product {
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

    //Function not used Ali* - Hamad
    // private func convertTransactionToType(transaction : Transaction.Transaction) : async Types.Transaction {
    //     return {
    //         id = await transaction.getID();
    //         productID = await transaction.getProductID();
    //         buyerID = await transaction.getBuyerID();
    //         paidPrice = await transaction.getPaidPrice();
    //     };
    // };

    private func convertUserToType(user : User.User) : async Types.User {
        return {
            name = await user.getName();
            buyersCart = await user.getBuyersCart();
            sellersStock = await user.getSellersStock();
            purchases = await user.getPurchases();
            soldItems = await user.getSoldItems();
            wallet = await user.getWallet();
        };
    };

    private func splitCycles<system>() {
        Cycles.add<system>(200000000000); // no warning or error
    };

    public func addToUserCart(userName: Text, product: Types.Product) : async Bool {
        for (user in userBuffer.vals()) { // check this or use the user array
          if (Text.equal(await user.getName(), userName)) {
              await user.addToCart(product);
              return true;
            };
        };
        return false;
    };

    public func clearUserCart(userName: Text) : async Bool {
        for (user in userBuffer.vals()) {
            if (Text.equal(await user.getName(), userName)) {
                await user.setBuyersCart([]);
                return true;
            };
        };
        return false; // User does not exist
    };

    public func removeFromUserCart(userName: Text, productID: Nat) : async Bool {
        for (user in userBuffer.vals()) {
            if (Text.equal(await user.getName(), userName)) {
                var currentCart = await user.getBuyersCart();
                let updatedCart = Array.filter(currentCart, func (p: Types.Product) : Bool { 
                    p.productID != productID 
                });
                if (currentCart.size() != updatedCart.size()) {
                    await user.setBuyersCart(updatedCart);
                    return true;
                };
                return false; // Product does not exist in cart
            };
        };
        return false; // User does not exist
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
        let user1=await createUser("user1");
        //await loginUser(user1);
        let user2=await createUser("user2");
        let price:Types.Price={
            currency = #usd;
            amount = 10;
        };
        let price2:Types.Price={
            currency = #usd;
            amount = 15;
        };
        let product1 =await createProduct("user1","prod1","cat1",price,"short","long",true,"null");
        let product2 =await createProduct("user2","prod2","cat1",price,"short","long",true,"null");
        let product3 =await createProduct("user2","prod3","cat1",price2,"short","long",true,"null");
        await purchase(user2,price,product1);
        await purchase(user2,price,product2);
        await purchase(user1,price,product3);
    };


};