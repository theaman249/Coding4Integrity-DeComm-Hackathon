import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import ICRC7 "mo:icrc7-mo";

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
        tokenID : Nat;
        productCategory : Text;
        productPicture : Text;
    };

    public type Transaction = {
        id : Nat;
        productID : Nat;
        buyerID : Text;
        paidPrice : Types.Price;
    };

    public type User = {
        name : Text;
        buyersCart : [Product];
        sellersStock : [Product];
        purchases : [Transaction];
        soldItems : [Transaction];
        wallet : [Types.Price];
    };
};

