import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Time "mo:base/Time";

module Types {
    public type Timestamp = Nat64;

    public type Currency = {
        #btc;
        #eth;
        #icp;
        #usd;
        #eur;
        #gbp;
        #kt;
    };

    public type Price = {
        currency : Currency;
        amount : Nat;
    };

    public type PersonalDashboard = {
        fullname:Text;
        marketValueOfKT: Nat;
        walletBallanceKT: Nat;
    };

    public type Message = {
        msg: Text;
        timestamp: Time.Time;
    };

    //User Object Types
    public type Product = {
        sellerID : Text;
        name : Text;
        productPrice : Types.Price;
        productShortDesc : Text;
        productLongDesc : Text;
        isSold : Bool;
        isVisible : Bool;
        productID : Nat;
        productCategory : Text;
        productPicture : Text;
    };

    public type Transaction = {
        id : Nat;
        productID : Nat;
        buyerID : Text;
        paidPrice : Types.Price;
    };

    public type Transfer ={
        sourceWalletID: Text;
        destinationWalletID : Text;
        transactionType: Text; //debit or credit
        amount : Types.Price;
        timestamp : Time.Time;
    };

    public type User = {
        name : Text;
        email: Text;
        walletID: Text;
        message: Text;
        buyersCart : [Product];
        sellersStock : [Product];
        purchases : [Transaction];
        soldItems : [Transaction];
        wallet : [Types.Price];
    };

    public type test = {
        name: Text;
        surname : Text;
    };
};
