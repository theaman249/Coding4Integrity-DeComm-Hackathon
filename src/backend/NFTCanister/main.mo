import ICRC7Default "./icrc7";
import ICRC37Default "./icrc37";
import ICRC3Default "./icrc3";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Types "../commons/NFTypes";
import ICRC7 "mo:icrc7-mo";
import ICRC37 "mo:icrc37-mo";
import ICRC3 "mo:icrc3-mo";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import D "mo:base/Debug";
import CertifiedData "mo:base/CertifiedData";
import CertTree "mo:cert/CertTree";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat8";
import Blob "mo:base/Blob";
import Option "mo:base/Option";

shared(_init_msg) actor class NFTCanister(_args : {
    icrc7_args: ?ICRC7.InitArgs;
    icrc37_args: ?ICRC37.InitArgs;
    icrc3_args: ICRC3.InitArgs;
}) = this {

    stable var init_msg = _init_msg;

    stable var icrc7_migration_state = ICRC7.init(
        ICRC7.initialState() , 
        #v0_1_0(#id), 
        switch(_args.icrc7_args){
        case(null) ICRC7Default.defaultConfig(init_msg.caller);
        case(?val) val;
    },init_msg.caller);

    let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state;

    stable var icrc37_migration_state = ICRC37.init(
        ICRC37.initialState() , 
        #v0_1_0(#id), 
        switch(_args.icrc37_args){
        case(null) ICRC37Default.defaultConfig(init_msg.caller);
        case(?val) val;
    }, init_msg.caller);

    let #v0_1_0(#data(icrc37_state_current)) = icrc37_migration_state;

    stable var icrc3_migration_state = ICRC3.init(
        ICRC3.initialState() ,
        #v0_1_0(#id), 
        switch(_args.icrc3_args){
        case(null) ICRC3Default.defaultConfig(init_msg.caller);
        case(?val) ?val : ICRC3.InitArgs;
    }, init_msg.caller);

    let #v0_1_0(#data(icrc3_state_current)) = icrc3_migration_state;

    private var _icrc7 : ?ICRC7.ICRC7 = null;
    private var _icrc37 : ?ICRC37.ICRC37 = null;
    private var _icrc3 : ?ICRC3.ICRC3 = null;

    private func get_icrc7_state() : ICRC7.CurrentState {
        return icrc7_state_current;
    };

    private func get_icrc37_state() : ICRC37.CurrentState {
        return icrc37_state_current;
    };

    private func get_icrc3_state() : ICRC3.CurrentState {
        return icrc3_state_current;
    };

    private var canister_principal : ?Principal = null;

    private func get_canister() : Principal {
        switch (canister_principal) {
            case (null) {
                canister_principal := ?Principal.fromActor(this);
                Principal.fromActor(this);
            };
            case (?val) {
                val;
            };
        };
    };

    private func updated_certification(cert: Blob, lastIndex: Nat) : Bool{
        D.print("updating the certification " # debug_show(CertifiedData.getCertificate(), ct.treeHash()));
        ct.setCertifiedData();
        D.print("did the certification " # debug_show(CertifiedData.getCertificate()));
        return true;
    };

    private func get_time() : Int{
        Time.now();
    };

    stable let cert_store : CertTree.Store = CertTree.newStore();
    let ct = CertTree.Ops(cert_store);

    private func get_certificate_store() : CertTree.Store {
        D.print("returning cert store " # debug_show(cert_store));
        return cert_store;
    };

    private func get_icrc3_environment() : ICRC3.Environment{
        ?{
            updated_certification = ?updated_certification;
            get_certificate_store = ?get_certificate_store;
        };
    };

    private func get_icrc7_environment() : ICRC7.Environment {
        {
        canister = get_canister;
        get_time = get_time;
        refresh_state = get_icrc7_state;
        add_ledger_transaction = ?icrc3().add_record;
        can_mint = null;
        can_burn = null;
        can_transfer = null;
        can_update = null;
        };
    };

    private func get_icrc37_environment() : ICRC37.Environment {
        {
        canister = get_canister;
        get_time = get_time;
        refresh_state = get_icrc37_state;
        icrc7 = icrc7();
        can_transfer_from = null;
        can_approve_token = null;
        can_approve_collection = null;
        can_revoke_token_approval = null;
        can_revoke_collection_approval = null;
        };
    };

    private func icrc3() : ICRC3.ICRC3 {
        switch(_icrc3) {
            case(null) {
                let icrc3 = ICRC3.ICRC3(?icrc3_migration_state, Principal.fromActor(this), get_icrc3_environment());
                D.print("ensure should be done: " # debug_show(icrc3.supported_block_types()));
                _icrc3 := ?icrc3;
                icrc3
            };
            case(?icrc3) icrc3;
        }
    };

    private func icrc7() : ICRC7.ICRC7 {
        switch(_icrc7) {
            case(null) {
                let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, Principal.fromActor(this), get_icrc7_environment());
                _icrc7 := ?icrc7;
                icrc7
            };
            case(?icrc7) icrc7;
        }
    };

    private func icrc37() : ICRC37.ICRC37 {
        switch(_icrc37) {
            case(null) {
                let icrc37 = ICRC37.ICRC37(?icrc37_migration_state, Principal.fromActor(this), get_icrc37_environment());
                _icrc37 := ?icrc37;
                icrc37
            };
            case(?icrc37) icrc37;
        }
    };

    // ICRC-7 Endpoints
    public shared(msg) func icrc7_mint(tokens : ICRC7.SetNFTRequest) : async [ICRC7.SetNFTResult] {
        let result = icrc7().set_nfts<system>(msg.caller, tokens, true);
        switch (result) {
            case(#ok(val)) val;
            case(#err(err)) D.trap(err);
        }
    };

    public query func icrc7_balance_of(account: Types.Account) : async Nat {
        icrc7().balance_of([account])[0]
    };

    public query func icrc7_owner_of(token_id: Nat) : async ?Types.Account {
        icrc7().owner_of([token_id])[0]
    };

    public shared(msg) func icrc7_transfer(args: Types.TransferArgs) : async [?ICRC7.TransferResult] {
        let result = icrc7().transfer<system>(msg.caller, [args]);
    };

    // ICRC-37 Endpoints
    public shared(msg) func icrc37_approve_tokens(args: Types.ApproveTokenArg) : async Result.Result<Nat, Text> {
        let result = icrc37().approve_tokens<system>(msg.caller, [args]);
        switch (result[0]) {
            case (?#Ok(id)) #ok(id);
            case (?#Err(err)) #err(debug_show(err));
            case (null) #err("Unexpected null result");
        }
    };

    public shared(msg) func icrc37_transfer_from(args: Types.TransferFromArg) : async Result.Result<Nat, Types.TransferError> {
        let result = icrc37().transfer_from<system>(msg.caller, [args]);
        switch (result[0]) {
            case (?#Ok(id)) #ok(id);
            case (?#Err(err)) #err(err);
            case (null) #err(#GenericError({error_code = 0; message = "Unexpected null result"}));
        }
    };

    public query func icrc37_is_approved(args: Types.IsApprovedArg) : async Bool {
        icrc37().is_approved([args])[0]
    };

    // ICRC-3 Endpoints
    public func icrc3_get_blocks(start: Nat, length: Nat) : async ICRC3.GetBlocksResult {
        icrc3().get_blocks([{start; length}])
    };

    public query func icrc3_get_archives(args: ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult {
        icrc3().get_archives(args)
    };

    // public shared(msg) func test_create_collection() : async Result.Result<(), Text> {
    //     let nftData = [
    //         {
    //             name = "Image 1";
    //             description = "A beautiful space image from NASA.";
    //             url = "https://images-assets.nasa.gov/image/PIA18249/PIA18249~orig.jpg";
    //         },
    //         {
    //             name = "Image 2";
    //             description = "Another stunning NASA image.";
    //             url = "https://images-assets.nasa.gov/image/GSFC_20171208_Archive_e001465/GSFC_20171208_Archive_e001465~orig.jpg";
    //         },
    //         {
    //             name = "Image 3";
    //             description = "Hubble sees the wings of a butterfly.";
    //             url = "https://images-assets.nasa.gov/image/hubble-sees-the-wings-of-a-butterfly-the-twin-jet-nebula_20283986193_o/hubble-sees-the-wings-of-a-butterfly-the-twin-jet-nebula_20283986193_o~orig.jpg";
    //         },
    //         {
    //             name = "Image 4";
    //             description = "Another beautiful image from NASA archives.";
    //             url = "https://images-assets.nasa.gov/image/GSFC_20171208_Archive_e001518/GSFC_20171208_Archive_e001518~orig.jpg";
    //         }
    //     ];

    //     var counter : Nat = 0;
    //     let mintRequests = Array.map<{name: Text; description: Text; url: Text}, ICRC7.SetNFTItemRequest>(nftData, func(data) {
    //         let tokenId = counter;
    //         counter += 1;
    //         {
    //             token_id = tokenId;
    //             owner = ?{ owner = Principal.fromActor(this); subaccount = null };
    //             metadata = #Map([
    //                 {
    //                     key = "icrc97:metadata";
    //                     value = #Map([
    //                         { key = "name"; value = #Text(data.name) },
    //                         { key = "description"; value = #Text(data.description) },
    //                         {
    //                             key = "assets";
    //                             value = #Array([
    //                                 #Map([
    //                                     { key = "url"; value = #Text(data.url) },
    //                                     { key = "mime"; value = #Text("image/jpeg") },
    //                                     { key = "purpose"; value = #Text("icrc97:image") }
    //                                 ])
    //                             ])
    //                         }
    //                     ])
    //                 }
    //             ]);
    //             memo = ?Blob.fromArray([0, 1]);
    //             override = true;
    //             created_at_time = null;
    //         }
    //     });

    //     let mintResult = await icrc7_mint(mintRequests);

    //     for (result in mintResult.vals()) {
    //         switch (result) {
    //             case (#Ok(?_)) {};
    //             case (#Ok(null)) {};
    //             case (#Err(err)) return #err("Failed to mint NFT: " # debug_show(err));
    //             case (#GenericError {error_code; message}) return #err("Generic error occurred: Code " # Nat.toText(error_code) # " - " # message);
    //         };
    //     };

    //     #ok()
    // };

    public shared(msg) func test_workflow() : async Result.Result<(), Text> {
        // 1. Create collection
        // let create_result = await test_create_collection();
        // switch (create_result) {
        //     case (#err(e)) return #err("Failed to create collection: " # e);
        //     case (#ok()) {};
        // };

        // 2. Check balance
        let balance = await icrc7_balance_of({owner = msg.caller; subaccount = null});
        if (balance != 5) {
            return #err("Unexpected balance. Expected 5, got " # Nat.toText(balance));
        };

        // 3. Approve transfer
        let approve_result = await icrc37_approve_tokens({
            token_id = 0;
            approval_info = {
                from_subaccount = null;
                spender = {owner = Principal.fromText("aaaaa-aa"); subaccount = null};
                memo = null;
                expires_at = null;
                created_at_time = null;
            };
        });
        switch (approve_result) {
            case (#err(e)) return #err("Failed to approve token: " # e);
            case (#ok(_)) {};
        };

        // 4. Check approval
        let is_approved = await icrc37_is_approved({
            spender = {owner = Principal.fromText("aaaaa-aa"); subaccount = null};
            from_subaccount = null;
            token_id = 0;
        });
        if (not is_approved) {
            return #err("Token approval failed");
        };

        // 5. Transfer token
        let transfer_result = await icrc7_transfer({
            from_subaccount = null;
            to = {owner = Principal.fromText("aaaaa-aa"); subaccount = null};
            token_id = 0;
            memo = null;
            created_at_time = null;
        });

        switch (transfer_result[0]) {
            case (?#Ok(_))  {};
            case (?#Err(e))  return #err("Failed to transfer token: " # debug_show(e));
            case (null)  return #err("Unexpected null result from transfer");
        };

        // 6. Check transaction log
        let blocks = await icrc3_get_blocks(0, 10);
        if (blocks.blocks.size() < 3) {  // We expect at least 3 transactions: mint, approve, transfer
            return #err("Unexpected number of transactions in the log");
        };

        #ok()
    };

    public query func get_stats() : async {
        total_supply: Nat;
        total_transactions: Nat;
    } {
        {
            total_supply = icrc7().total_supply();
            total_transactions = icrc3().stats().localLedgerSize;
        }
    };
}