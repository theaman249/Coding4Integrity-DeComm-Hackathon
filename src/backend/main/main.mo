import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Error "mo:base/Error";

import Types "../commons/Types";
import Product "Product";
import Transaction "Transaction";
import User "User";
import Random "mo:base/Random";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Char "mo:base/Char";
import Time "mo:base/Time"


//Actor
actor class Main() {
    let nftCanister = actor("bw4dl-smaaa-aaaaa-qaacq-cai") : actor {
        test_create_collection: shared(name: Text, shortDesc: Text, picture: Text) -> async Bool;
        test_workflow: shared(recipient : Text, name: Text, description: Text, url: Text) -> async Result.Result<(), Text>;
        get_last_minted_token_id : shared() -> async ?Nat;
        transferNFT : shared(tokenID: Nat) -> async Result.Result<(), Text>;
    };

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

    public func createUser<system>(name : Text, email : Text, password : Text) : async Types.User{

        Cycles.add<system>(100_000_000_000); // 8 billion cycles

        let dummy = await User.User(
            "null",
            "null",
            0,
            "null", // insert generateWalletID here
            [],
            [],
            [],
            [],
            [],
            []
        );

        var flag : Bool = false;
        let usernames = await getAllUserEmails();
        for (username in usernames.vals()) {
            if (Text.equal(email, username)) {
                flag := true;
                let result = await convertUserToType(dummy,"user already exists");
                return result;
            };
        };
        
        Cycles.add<system>(1_000_000_000); // 8 billion cycles

        let hashedPassword = Text.hash(password);

        let walletID = await generateWalletID();

        Cycles.add<system>(400_000_000_000); // 8 billion cycles

        let user = await User.User(
            name,
            email,
            hashedPassword,
            walletID, // insert generateWalletID here
            [],
            [],
            [],
            [],
            [
                { currency = #kt; amount = 1000000000000 },
            ],
            []
        );

        await updateUserArray(user);
        let result = await convertUserToType(user,"user created successfully");
        return result;
    };

    public func generateWalletID<system>(): async Text {
        // Initialize an empty Text variable for the wallet ID
        var walletID: Text = "";

        let charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var f = Random.Finite(await Random.blob());

        var n = 0;
        while(n < 4){
            
            for(j in Iter.range(0, 4)) //upper bound is inclusive
            {
                let ran = generateRandomNumber(f,35);
            
                switch(ran){
                    case(?value){

                        let character = await getCharAtIndex(value,charset);

                        walletID :=  walletID # character;
                    };
                    case _{
                        Debug.print("Unable to obtain random value");
                    };
                };
            };

            if(n < 3){
                walletID := walletID # "-";
            };

            n := n+1;
        };

        return walletID;
    };

    public func testObject(): async Text {
        let users = await getAllUsers();
        for (user in users.vals()) {
            let walletID = await user.getWalletID();
            return walletID;
        };

        return "Money for Fun";
    };

    public func transferTokens(destinationWalletID: Text, amount:Nat): async Types.Message  {
        
        //check if receiver exists

        let reciever = await getUserByWalletID(destinationWalletID);

        switch (reciever) {
            case (?recieverUser) {
                //get sender
                let sender = await getUserByEmail(await WhoIsLoggedIn());

                switch(sender) {

                    case(?senderUser){

                        //Don't allow a user to send money to themselves
                        let recieverWalletID = await recieverUser.getWalletID();
                        let senderWalletID = await senderUser.getWalletID();

                        if(recieverWalletID == senderWalletID)
                        {   
                            return {
                                msg = "Transaction failed. Invalid walletID";
                                timestamp = Time.now();
                            }; 
                        };

                        let money: Types.Price={
                            currency = #kt;
                            amount = amount;
                        };
                        
                        let credit: Types.Transfer = {
                            sourceWalletID = senderWalletID;
                            destinationWalletID = destinationWalletID;
                            transactionType = "credit";
                            amount = money;
                            timestamp = Time.now();
                        };

                        let debit: Types.Transfer = {
                            sourceWalletID = senderWalletID;
                            destinationWalletID = destinationWalletID;
                            transactionType = "debit";
                            amount = money;
                            timestamp = Time.now();
                        };

                        await senderUser.addToTransfer(debit);
                        await recieverUser.addToTransfer(credit);

                        await recieverUser.addToWallet(money);

                        let result = await senderUser.takeFromWallet(money);

                        switch (result) {
                            case (#ok(())) {
                                return {
                                    msg = "tokens sent to wallet " # destinationWalletID;
                                    timestamp = Time.now();
                                };
                            };
                            case (#err(errorMsg)) {
                                return {
                                    msg = errorMsg;
                                    timestamp = Time.now();
                                };
                            };
                        };
                    };

                    case(null){
                        return {
                            msg = "Sender not found";
                            timestamp = Time.now();
                        };
                    };
                };
            };
            case (null) {
                return {
                    msg = "Reciever not found";
                    timestamp = Time.now();
                }
                
            };
        };
    };


    public func getCharAtIndex(index: Nat,word: Text): async Text {
        
        // Get an iterator for the string
        let iter = Text.toIter(word);
        
        // Iterate over the characters until you reach the desired index
        var currentIndex: Nat = 0;
        
        // Loop over the iterator and get the character at the specified index
        while (currentIndex <= index) {
            switch (iter.next()) {
                case (?c) {
                    if (currentIndex == index) {
                        return Text.fromChar(c);  // Return the character as Text when index is found
                    };
                    currentIndex += 1;
                };
                case null {
                    // If we reach the end of the string before finding the index
                    return " ";  // Return a default character or handle out of bounds as needed
                };
            };
        };
    
        return " ";  // Return a default character if index is out of bounds
    };

    public func testRandomiser(): async ?Nat{
        var f = Random.Finite(await Random.blob());
        let result = generateRandomNumber(f,32);
        return result;
    };


    func generateRandomNumber(f : Random.Finite, max : Nat) : ? Nat {
        assert max > 0;
        do ? {
        var n = max - 1 : Nat;
        var k = 0;
        while (n != 0) {
            k *= 2;
            k += bit(f.coin()!);
            n /= 2;
        };
        if (k < max) k else generateRandomNumber(f, max)!;
        };
    };

    func bit(b : Bool) : Nat {
        if (b) 1 else 0;
    };



    private func updateUserArray(user : User.User) : async () {
        userBuffer.add(user);
        usersArray := Buffer.toArray<User.User>(userBuffer);
    };

    
    public func loginUser<system>(username : Text, password:Text) : async Types.User {
        
        Cycles.add<system>(100_000_000_000); // 200 billion cycles


        let dummy = await User.User(
            "null",
            "null",
            0,
            "null", // insert generateWalletID here
            [],
            [],
            [],
            [],
            [],
            []
        );
        
        
        for (index in usersArray.vals()) {
            if (Text.equal(username, await index.getEmail())) {

                let foundUser:User.User = index;
                let hashedPassword = Text.hash(password);
                let pHash = await foundUser.getPHash();

                if(pHash == hashedPassword)
                {
                    loggedInUserEmail := username;
                    let result = await convertUserToType(foundUser,"user successfully logged in");
                    return result;
                }
                else{
                    let result = await convertUserToType(dummy,"authentication failed");
                    return result;
                }
            };
        };

        let result = await convertUserToType(dummy,"user does not exist");
        return result;
    };

    /*
    * This function returns the email of the current user
    * that is logged in
    */
    public func WhoIsLoggedIn(): async Text{
        return loggedInUserEmail;
    };


    public query func getAllUsers() : async [User.User] {
        return usersArray;
    };

    public func getAllUsersTypesFromObjectArray(userObjList : [User.User]) : async [Types.User] {
        let typeBuffer = Buffer.Buffer<Types.User>(0);
        for (user in userObjList.vals()) {
            typeBuffer.add(await (convertUserToType(user,"getAllUsersTypesFromObjectArray")));
        };
        return Buffer.toArray(typeBuffer);
    };

    public func getAllUserTypes() : async [Types.User] {
        return await (getAllUsersTypesFromObjectArray(await getAllUsers()));
    };

    public func convertUserToType(user : User.User,msg: Text) : async Types.User {
        return {
            name = await user.getName();
            email = await user.getEmail();
            pHash = await user.getPHash();
            walletID = await user.getWalletID();
            message = msg;
            buyersCart = await user.getBuyersCart();
            sellersStock = await user.getSellersStock();
            purchases = await user.getPurchases();
            soldItems = await user.getSoldItems();
            wallet = await user.getWallet();
        };
    };

    //add new nft definition for product (test_create_collection)
    public func createProduct<system>(user : Text, name : Text, category : Text, price : Types.Price, shortDesc : Text, longDesc : Text, isVisible : Bool, picture : Text) : async Product.Product{
        splitCycles<system>();

        //Get newly minted nft tokenid
        let collectionResult = await nftCanister.test_create_collection(name, shortDesc, picture);

        if (collectionResult) {
            let tokenIdOpt = await nftCanister.get_last_minted_token_id();
            
            switch (tokenIdOpt) {
                case (?tokenId) {
                    var product = await Product.Product(user, name, category, price, shortDesc, longDesc, isVisible, picture, productIDNum, tokenId);
                    productIDNum := productIDNum + 1;
                    await updateProductArray(product);
                    
                    return product;
                };
                case null {
                     throw Error.reject("No token ID returned after successful collection creation.");
                };
            }
        } else {
            // Handle failure of collection creation
            throw Error.reject("Failure during collection creation.");
    };
        throw Error.reject("Unexpected error during collection creation.");
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

    public func getDataForPersonalDashboard(): async Types.PersonalDashboard{
        let email = await WhoIsLoggedIn();
        let userOpt = await getUserByEmail(email);

        switch (userOpt) {
            case (?user) {

                var balanceOfKT = 0;
                let userWallet = await user.getWallet();
                let name = await user.getName();

                for (j in userWallet.vals())
                {
                    if(j.currency == #kt) {
                        balanceOfKT += j.amount;
                    }   
                };

                return {
                    fullname = name;
                    marketValueOfKT = 10000;
                    walletBallanceKT = balanceOfKT;
                };
            };
            case (null) {
                Debug.print("User not found");
                return {
                    fullname = "null";
                    marketValueOfKT = 0;
                    walletBallanceKT = 0;
                }
            };
        };
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
            tokenID = await product.getTokenID();
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

    
    /*
    * This function returns all transactions made by the user.
    * The transactions cover the buying and selling products 
    */
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

    public func getUserByEmail(email : Text) : async ?User.User {
        let users = await getAllUsers();
        for (user in users.vals()) {
            let userEmail = await user.getEmail();
            if (Text.equal(email, userEmail)) {
                return ?user;
            };
        };
        return null;
    };

    public func viewProfile(email:Text): async Types.User{
        let users = await getAllUsers();
        for (user in users.vals()) {
            let userEmail = await user.getEmail();
            if (Text.equal(email, userEmail)) {
                return await convertUserToType(user,"view profile");
            };
        };

        Cycles.add<system>(100_000_000_000); // 200 billion cycles


        let dummy = await User.User(
            "null",
            "null",
            0,
            "null", // insert generateWalletID here
            [],
            [],
            [],
            [],
            [],
            []
        );

        return await convertUserToType(dummy, "profile not found");
    };

    public func getUserByWalletID(walletID: Text): async ?User.User {
        let users = await getAllUsers();
        for (user in users.vals()) {
            let userWalletID = await user.getWalletID();
            if (Text.equal(userWalletID, walletID)) {
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

    public func getUserProductIDs(name : Text) : async [Nat] {
        let userObjOpt = await getUserByName(name);
        
        switch (userObjOpt) {
        case (null) {
            // Handle the case where the user is not found
            Debug.print("User not found: " # name);
            return []; // Return an empty array if user is not found
        };
        case (?userObj) {
            // Call getProductIDs on the retrieved user object
            return await userObj.getProductIDs();
        };
    };
    };

    //add the buyer to nft as subowner 
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
                        let name = await product.getName();
                        let descr = await product.getShortDesc();
                        let picture = await product.getPicture();
                        let tokenID = await product.getTokenID();

                        let purchaseResult = await nftCanister.transferNFT(tokenID);

                        //let workflowResult = await NFTCanister.test_workflow(name, descr, picture);
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

    // User class functions
    public func getAllUserTransfers(email:Text): async [Types.Transfer]{
        let users = await getAllUsers();
        for (user in users.vals()) {
            let userEmail = await user.getEmail();
            if (Text.equal(userEmail, email)) {
                return await user.getTransfers();
            };
        };
        return [];
    };

    private func findUser(userName : Text) : async ?User.User {
        for (user in usersArray.vals()) {
            if (Text.equal(userName, await user.getName())) {
                return ?user;
            };
        };
        null;
    };


};