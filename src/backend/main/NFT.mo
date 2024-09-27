import Buffer "mo:base/Buffer";
import Types "../commons/Types";

/*type NFTActor = actor {
    // Properties
    var token_id: Nat;
    var token_owner: Text;  
    var token_descr: Text;
    var token_pictureURL: Text;
    var token_subOwners: [Text];
    var token_productId: Nat;

    // Buffer for subowners
    var subownersBuffer: Buffer<Text>;

    // Queries
    public query func getTokenID() : async Nat {
        return token_id;
    };

    public query func getOwner() : async Text {
        return token_owner;
    };

    public query func getShortDesc() : async Text {
        return token_descr;
    };

    public query func getPictureURL() : async Text {
        return token_pictureURL;
    };

    public query func getSubowners() : async [Text] {
        return token_subOwners;
    };

    public query func getProductId() : async Nat {
        return token_productId;
    };

    public query func getNFTDetails() : async Types.NFT {
        return {
            tokenID = token_id;
            shortDescr = token_descr;
            pictureURL = token_pictureURL;
            owner = token_owner;
            subOwners = token_subOwners;
            productID = token_productId;
        };
    };

    // Mutators

    public func init(id: Nat,
        owner: Text,
        descr: Text,
        pictureURL: Text,
        subOwners: [Text],
        productId: Nat) : async () {

        token_id := id;
        token_owner := owner;
        token_descr := descr;
        token_pictureURL := pictureURL;
        token_subOwners := subOwners;
        token_productId := productId;
        subownersBuffer := Buffer.fromArray<Text>(subOwners);
    };

    public func setOwner(newOwner: Text) : async () {
        token_owner := newOwner;  
    };

    public func setDescr(descr: Text) : async () {
        token_descr := descr;
    };

    public func setPictureURL(pictureURL: Text) : async () {
        token_pictureURL := pictureURL;
    };

    public func setSubowners(subOwners: [Text]) : async () {
        token_subOwners := subOwners;
        subownersBuffer := Buffer.fromArray<Text>(subOwners); // Update buffer when setting new subowners
    };

    public func setProductId(productId: Nat) : async () {
        token_productId := productId;
    };

    public func addSubOwner(newSubowner: Text) : async () {
        subownersBuffer.add(newSubowner);
        await setSubowners(Buffer.toArray(subownersBuffer));
    };
};
*/

actor class NFTActor(
    tokenID: Nat, 
    shortDescr: Text, 
    pictureURL: Text, 
    owner: Text, 
    subOwners: [Text],
    productID: Nat) {

    var token_id: Nat = tokenID;
    var token_owner: Text = owner;  
    var token_descr: Text = shortDescr;
    var token_pictureURL: Text = pictureURL;
    var token_subOwners: [Text] = subOwners;
    var token_productId: Nat = productID;

    var subownersBuffer = Buffer.fromArray<Text>(token_subOwners);

    public query func getTokenID() : async Nat {
        return token_id;
    };

    public query func getOwner() : async Text {
        return token_owner;
    };

    public query func getShortDesc() : async Text {
        return token_descr;
    };

    public query func getPictureURL() : async Text {
        return token_pictureURL;
    };

    public query func getSubowners() : async [Text] {
        return token_subOwners;
    };

    public query func getProductId() : async Nat {
        return token_productId;
    };


    public func setOwner(newOwner: Text) : async () {
        token_owner := newOwner;  
    };

    public func setDescr(descr: Text) : async () {
        token_descr := descr;
    };

    public func setPictureURL(pictureURL: Text) : async () {
        token_pictureURL := pictureURL;
    };

    public func setSubowners(subOwners: [Text]) : async () {
        token_subOwners := subOwners;
    };

    public func setProductId(productId: Nat) {
        token_productId := productId;
    };

    public func addSubOwner(newSubowner: Text) : async () {
        subownersBuffer.add(newSubowner);
        await setSubowners(Buffer.toArray(subownersBuffer));
    };

    public query func getNFTDetails() : async Types.NFT {
    return {
        tokenID = token_id;
        shortDescr = token_descr;
        pictureURL = token_pictureURL;
        //owner = token_owner;
        subOwners = token_subOwners;
        productID = token_productId;
    };
};
};
