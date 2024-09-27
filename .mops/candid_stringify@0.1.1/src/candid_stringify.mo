import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Order "mo:base/Order";
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";

import Arg "mo:candid/Arg";
import Decoder "mo:candid/Decoder";
import Encoder "mo:candid/Encoder";
import Tag "mo:candid/Tag";
import Type "mo:candid/Type";
import Value "mo:candid/Value";
import { hashName } "mo:candid/Tag";

import T "types";

module {
    type Arg = Arg.Arg;
    type Type = Type.Type;
    type Value = Value.Value;
    type RecordFieldType = Type.RecordFieldType;
    type RecordFieldValue = Value.RecordFieldValue;

    type KeyValuePair = T.KeyValuePair;

    public func stringify(blob : Blob, recordKeys : [Text]) : Text {
        let res = Decoder.decode(blob);
       
        let keyEntries = Iter.map<Text, (Nat32, Text)>(
            recordKeys.vals(),
            func(key : Text) : (Nat32, Text) {
                (hashName(key), key);
            },
        );

        let recordKeyMap = TrieMap.fromEntries<Nat32, Text>(
            keyEntries,
            Nat32.equal,
            func(n : Nat32) : Hash.Hash = n,
        );
        
        switch (res) {
            case (?args) {
                fromArgs(args, recordKeyMap);                
            };
            case (_) { 
                Debug.print("here unreachable");
                Prelude.unreachable()
             };
        };
    };

    public func fromArgs(args : [Arg], recordKeyMap : TrieMap.TrieMap<Nat32, Text>) : Text {
        let arg = args[0];
        fromArgValueToText(arg._type, arg.value, recordKeyMap);  
    };

    func fromArgValueToText(_type : Type, val : Value, recordKeyMap : TrieMap.TrieMap<Nat32, Text>) : Text {
       
        switch (_type, val) {
            case (_, #nat(n)) Int.toText(n);
            case (_, #nat8(n)) Int.toText(Prim.nat8ToNat(n));
            case (_, #nat16(n)) Int.toText(Prim.nat16ToNat(n));
            case (_, #nat32(n)) Int.toText(Prim.nat32ToNat(n));
            case (_, #nat64(n)) Int.toText(Prim.nat64ToNat(n));
          
            case (_, #int(n)) Int.toText(n);
            case (_, #int8(n)) Int.toText(Prim.int8ToInt(n));
            case (_, #int16(n)) Int.toText(Prim.int16ToInt(n));
            case (_, #int32(n)) Int.toText(Prim.int32ToInt(n));
            case (_, #int64(n)) Int.toText(Prim.int64ToInt(n));

            case (_, #float(n)) Float.toText(n);

            case (_, #bool(b)) Bool.toText(b);

            case (_, #principal(service)) {
                switch (service) {
                    case (#transparent(p)) {                       
                        "principal " # Principal.toText(p);
                    };
                    case (_) Prelude.unreachable();
                };
            };

            case (_, #text(n)) {n};

            case (_, #_null) {"null"};

            case (optionType, #opt(optVal)) {
                let val = switch (optionType, optVal) {
                    case (#opt(#_null), _) "null";
                    case (#opt(_), null) "null";
                    case (#opt(innerType), ?val) {
                        fromArgValueToText(innerType, val, recordKeyMap);
                    };
                    case (_) Debug.trap("Expected value in #opt");
                };
             
                "opt " # val;
            };

            case (vectorType, #vector(arr)) {                 
                var res : Text = "{ ";
                switch (vectorType) {
                    case (#vector(#nat8)) {
                        let bytes = Array.map(
                            arr,
                            func(elem : Value) : Text {
                                switch (elem) {
                                    case (#nat8(n)) Int.toText(Prim.nat8ToNat(n));
                                    case (_) Debug.trap("Expected nat8 in #vector");
                                };
                            },
                        );
                       
                        for(i in bytes.vals()){                           
                            res #= i # ", ";
                        };
                        return res # " }";
                    };
                    case (#vector(innerType)) {
                        let newArr = Array.map(
                            arr,
                            func(elem : Value) : Text {
                                fromArgValueToText(innerType, elem, recordKeyMap);
                            },
                        );                       
                        for(i in newArr.vals()){                           
                            res #= i # ", ";
                        };
                        return res # " }";
                    };
                    case (_) Debug.trap("Mismatched type '" # debug_show (vectorType)# "'' to value of '#vector'");
                };
            };

            case (#record(recordTypes), #record(records)) {
                var k : Text = "";
                var v : Text = "";
                var localBuffer = Buffer.Buffer<(Text,Text)>(0); 
                let newRecords = Array.tabulate(
                    records.size(),
                    func (i: Nat): KeyValuePair {
                        let {_type = innerType} = recordTypes[i];
                        let {tag; value} = records[i];

                        let key = getKey(tag, recordKeyMap);
                        let val = fromArgValueToText(innerType, value, recordKeyMap);
                        k := key;
                        v := val;
                        localBuffer.add((k,val));
                       
                        (key, #Text(val))
                    },
                ); 
                
                
                // let sortedRecords = Array.sort(localBuffer.toArray(), U.cmpRecords);
                let localArray = localBuffer.toArray();
               
                var response : Text = ""; 
                for(i in localArray.vals()){                    
                    response #= i.0 # " = " # i.1 # "; ";                
                };
             
                "record { " # response # " }";               
            };
          
            case (#variant(variantTypes), #variant(v)) {
                
                for ({tag; _type = innerType} in variantTypes.vals()) {
                    if (tag == v.tag) {
                        let key = getKey(tag, recordKeyMap);
                        let val = fromArgValueToText(innerType, v.value, recordKeyMap);

                        return "variant { " # key # " = " # val # " }";
                    };
                };

                Debug.trap("Could not find variant type for '" # debug_show v.tag # "'");
            };

            case (_) { Prelude.unreachable() };
        };
       
    };
   

    func getKey(tag : Tag.Tag, recordKeyMap : TrieMap.TrieMap<Nat32, Text>) : Text {
        switch (tag) {
            case (#hash(hash)) {
                switch (recordKeyMap.get(hash)) {
                    case (?key) key;
                    case (_) debug_show hash;
                };
            };
            case (#name(key)) key;
        };
    };

    public func cmpRecords(a : (Text, Any), b : (Text, Any)) : Order.Order {
        Text.compare(a.0, b.0);
    };
};

