import Text "mo:base/Text";

actor class Wallet(
    email: Text,
    id: Text,
    balance: Int,
) {

    stable var userEmail: Text = email;
    stable var userID: Text = id;
    stable var userBalance: Int = balance;

    public func getBalance(): async Int {
        return balance;
    };

    public func getId(): async Text {
        return id;
    };

    public func getEmail(): async Text {
        return email;
    };

    public func setEmail(f_email: Text): async () {
        userEmail := f_email;
    };

    public func setId(f_id: Text): async () {
        userID := f_id;
    };

    public func credit(f_amount: Int): async () {
        userBalance := userBalance + f_amount;
    };

    public func debit(f_amount: Int): async () {
        userBalance := userBalance - f_amount;
    };
}
