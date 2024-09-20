import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Types "../commons/Types";
import Product "Product";
import Transaction "Transaction";
import User "User";
import Random "mo:base/Random";

//Actor
actor class Main() {
    stable var usersArray : [User.User] = [];
    stable var productsArray : [Product.Product] = [];
    stable var productIDNum : Nat = 0;
    stable var transactionsArray : [Transaction.Transaction] = [];
    stable var transactionIDNum : Nat = 0;

    var userBuffer = Buffer.fromArray<User.User>(usersArray);
    var productBuffer = Buffer.fromArray<Product.Product>(productsArray);
    var transactionBuffer = Buffer.fromArray<Transaction.Transaction>(transactionsArray);
    private var inCarts : Buffer.Buffer<(Text, Nat)> = Buffer.Buffer<(Text, Nat)>(0);

    var loggedInUserEmail:Text = "";

    public func addToCart(userID : Text, productID : Nat) : async Bool {
        if (not Buffer.contains(inCarts, (userID, productID), func(a : (Text, Nat), b : (Text, Nat)) : Bool { a.0 == b.0 and a.1 == b.1 })) {
            inCarts.add((userID, productID));
            Debug.print("Added to cart: " # debug_show ((userID, productID)));
            return true;
        };
        Debug.print("Product already in cart: " # debug_show ((userID, productID)));
        return false;
    };

    public func removeFromCart(userID : Text, productID : Nat) : async Bool {
        let beforeSize = inCarts.size();
        inCarts.filterEntries(
            func(index : Nat, item : (Text, Nat)) : Bool {
                not (item.0 == userID and item.1 == productID);
            }
        );
        let removed = inCarts.size() < beforeSize;
        Debug.print("Removed from cart: " # debug_show ((userID, productID)) # " Success: " # debug_show (removed));
        return removed;
    };

    public func isInCart(userID : Text, productID : Nat) : async Bool {
        Buffer.contains(inCarts, (userID, productID), func(a : (Text, Nat), b : (Text, Nat)) : Bool { a.0 == b.0 and a.1 == b.1 });
    };

    public func getAllUserNames() : async [Text] {
        let namebuffer = Buffer.Buffer<Text>(0);
        for (index in usersArray.vals()) {
            let name = await index.getName();
            namebuffer.add(name);
        };
        return Buffer.toArray(namebuffer);
    };

    public func getAllUserEmails() : async [Text] {
        let emailbuffer = Buffer.Buffer<Text>(0);
        for (index in usersArray.vals()) {
            let email = await index.getEmail();
            emailbuffer.add(email);
        };
        return Buffer.toArray(emailbuffer);
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

    public func createUser<system>(name : Text, email : Text, password : Text) : async Text{
        
        splitCycles<system>();

        let hashedPassword = Text.hash(password);

        let user = await User.User(
            name,
            email,
            hashedPassword,
            [],
            [],
            [],
            [],
            [
                { currency = #kt; amount = 1000000000000 },
            ]
        );

        var flag : Bool = false;
        let usernames = await getAllUserEmails();
        for (username in usernames.vals()) {
            if (Text.equal(email, username)) {
                flag := true;
                return await toJsonUser("null","null","user already exists");
            };
        };

        await updateUserArray(user);
        return await toJsonUser(name,email,"user successfully created");
    };

    public func generateWalletID(): async Text {
        // Initialize an empty Text variable for the wallet ID
        var walletID: Text = "";
        
        // Generate a random character from the charset by random index
        func randomChar(): Text {
            let randomIndex = Random.range(Nat32.fromInt(0), Nat32.fromNat(charset.size() - 1));
            return Text.fromChar(charset.charAt(randomIndex));
        };

        // Construct the wallet ID in the format XXXX-XXXX-XXXX-XXXX
        var partCount: Int = 0;
        for (i in Iter.range(0, 15)) {
            if (i > 0 and i % 4 == 0) {
                walletID #= "-";  // Insert a dash after every 4 characters
            };
            walletID #= randomChar();  // Add a random character to the wallet ID
        };

        return walletID;
    };


    private func updateUserArray(user : User.User) : async () {
        userBuffer.add(user);
        usersArray := Buffer.toArray<User.User>(userBuffer);
    };

    

    public func loginUser<system>(username : Text, password:Text) : async Text {
        
        Cycles.add<system>(200_000_000_000); // 200 billion cycles
        
        for (index in usersArray.vals()) {
            if (Text.equal(username, await index.getEmail())) {

                let foundUser:User.User = index;
                let hashedPassword = Text.hash(password);
                let name = await foundUser.getName();
                let email = await foundUser.getEmail();
                let pHash = await foundUser.getPHash();

                if(pHash == hashedPassword)
                {
                    loggedInUserEmail := username;
                    return await toJsonUser(name,email,"user successfully logged in");
                }
                else{
                    return await toJsonUser(name,email,"authentication failed"); 
                }
            };
        };

        return await toJsonUser("null","null","unable to login user");
    };

    public func WhoIsLoggedIn(): async Text{
        return loggedInUserEmail;
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
            email = await user.getEmail();
            pHash = await user.getPHash();
            buyersCart = await user.getBuyersCart();
            sellersStock = await user.getSellersStock();
            purchases = await user.getPurchases();
            soldItems = await user.getSoldItems();
            wallet = await user.getWallet();
        };
    };

    public func createProduct<system>(user : Text, name : Text, category : Text, price : Types.Price, shortDesc : Text, longDesc : Text, isVisible : Bool, picture : Text) : async Product.Product{
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

    public func test(): async Text{
        return "Hello from backend";
    };

    // public query func toJson(id: Text,name: Text,email: Text): async Text {
    //     return "{" #
    //         "\"id\": " # id # ", " #
    //         "\"name\": \"" # name # "\"," #
    //         "\"email\": \"" # email # "\"" #
    //     "}";
    // };

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

    public func editProduct(
        productID : Nat,
        username : Text,
        newName : Text,
        newCategory : Text,
        newPrice : Types.Price,
        newShortDesc : Text,
        newLongDesc : Text,
        newIsVisible : Bool,
    ) : async Result.Result<(), Text> {
        for (product in productsArray.vals()) {
            let prod = await convertProductToType(product);
            if (prod.productID == productID and Text.equal(username, prod.sellerID)) {
                await product.setName(newName);
                await product.setCategory(newCategory);
                await product.setPrice(newPrice);
                await product.setShortDesc(newShortDesc);
                await product.setLongDesc(newLongDesc);
                await product.setIsVisible(newIsVisible);
                return #ok(());
            };
        };
        return #err("Product not found or user is not the seller");
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

    public func createTransaction<system>(productID : Nat, buyerID : Text, paidPrice : Types.Price) : async Transaction.Transaction {
        Cycles.add<system>(200000000000);
        var transaction = await Transaction.Transaction(transactionIDNum, productID, buyerID, paidPrice);
        transactionIDNum := transactionIDNum + 1;
        let _temp = await updateTransactionArray(transaction);
        return transaction;
    };

    private func updateTransactionArray(transaction : Transaction.Transaction) : async () {
        transactionBuffer.add(transaction);
        transactionsArray := Buffer.toArray<Transaction.Transaction>(transactionBuffer);
    };

    public query func getAllTransactions() : async [Transaction.Transaction] {
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

    public func getAllTransactionTypesFromObjectArray(transactionObjList : [Transaction.Transaction]) : async [Types.Transaction] {
        let typeBuffer = Buffer.Buffer<Types.Transaction>(0);
        for (transaction in transactionObjList.vals()) {
            typeBuffer.add(await convertTransactionToType(transaction));
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getAllTransactionTypes() : async [Types.Transaction] {
        return await getAllTransactionTypesFromObjectArray(await getAllTransactions());
    };

    private func splitCycles<system>() {
        Cycles.add<system>(200000000000);
    };

    public func addToUserCart(userName : Text, product : Types.Product) : async Bool {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                if (await addToCart(userName, product.productID)) {
                    await user.addToCart(product);
                    Debug.print("Added to user cart: " # userName # ", Product: " # debug_show (product.productID));
                    return true;
                } else {
                    Debug.print("Failed to add to user cart: " # userName # ", Product: " # debug_show (product.productID));
                    return false;
                };
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return false;
            };
        };
    };

    public func removeFromUserCart(userName : Text, productID : Nat) : async Bool {
        let userOpt = await findUser(userName);
        switch (userOpt) {
            case (?user) {
                if (await removeFromCart(userName, productID)) {
                    await user.removeFromCart(productID);
                    Debug.print("Removed from user cart: " # userName # ", Product: " # debug_show (productID));
                    return true;
                } else {
                    Debug.print("Failed to remove from user cart: " # userName # ", Product: " # debug_show (productID));
                    return false;
                };
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return false;
            };
        };
    };

    public func clearUserCart(userName : Text) : async Bool {
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
                Debug.print("User cart count: " # userName # ", Count: " # debug_show (cart.size()));
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
                Debug.print("Retrieved user cart: " # userName # ", Items: " # debug_show (cartProducts.size()));
                return cartProducts;
            };
            case (null) {
                Debug.print("User not found: " # userName);
                return [];
            };
        };
    };

    private func _getUserCartProductTypesFromObjectArray(cartProducts : [Types.Product]) : async [Types.Product] {
        let typeBuffer = Buffer.Buffer<Types.Product>(0);
        for (product in cartProducts.vals()) {
            typeBuffer.add(product);
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getUserByName(name : Text) : async ?User.User {
        let users = await getAllUsers();
        for (user in users.vals()) {
            let username = await user.getName();
            if (Text.equal(name, username)) {
                return ?user;
            };
        };
        return null;
    };

    public func getProductById(productID : Nat) : async Result.Result<Product.Product, Text> {
        for (product in productsArray.vals()) {
            let id = await product.getProductID();
            if (id == productID) {
                return #ok(product);
            };
        };
        return #err("Product not found");
    };

    public func purchase(name : Text, productID : Nat) : async Result.Result<(), Text> {
        let userObjOpt = await getUserByName(name);

        switch (userObjOpt) {
            case (null) {
                return #err("User not found");
            };
            case (?userObj) {
                let productResult = await getProductById(productID);

                switch (productResult) {
                    case (#err(errorMsg)) {
                        return #err(errorMsg);
                    };
                    case (#ok(product)) {
                        let sellerName = await product.getSellerID();
                        let productPrice = await product.getPrice();
                        let buyerID = await userObj.getName();

                        for (index in usersArray.vals()) {
                            let target = await index.getName();
                            if (Text.equal(target, sellerName)) {
                                let walletResult = await userObj.takeFromWallet(productPrice);
                                switch (walletResult) {
                                    case (#ok(())) {
                                        let transaction = await createTransaction(productID, buyerID, productPrice);
                                        let transactionType = await convertTransactionToType(transaction);
                                        await index.addToWallet(productPrice);
                                        await index.addToSoldItems(transactionType);
                                        await userObj.addToPurchases(transactionType);
                                        return #ok(());
                                    };
                                    case (#err(errorMsg)) {
                                        return #err("Error taking from wallet: " # errorMsg);
                                    };
                                };
                            };
                        };
                        return #err("Seller not found");
                    };
                };
            };
        };
    };

    public func clearDB() : async () {
        usersArray := [];
        productsArray := [];
        transactionsArray := [];
        productIDNum := 0;
        transactionIDNum := 0;
        userBuffer := Buffer.fromArray<User.User>(usersArray);
        productBuffer := Buffer.fromArray<Product.Product>(productsArray);
        transactionBuffer := Buffer.fromArray<Transaction.Transaction>(transactionsArray);
    };

    private func findUser(userName : Text) : async ?User.User {
        for (user in usersArray.vals()) {
            if (Text.equal(userName, await user.getName())) {
                return ?user;
            };
        };
        null;
    };



    private func toJsonUser(name: Text, email: Text, msg: Text): async Text {
        return "{" #
            "\"name\": \"" # name # "\", " #  // Name value in quotes
            "\"email\": \"" # email # "\", " #
            "\"message\": \"" # msg # "\"" #
        "}";
    }   


};