# 🚀 Candid Stringify


## Overview
A Motoko library to convert any [Candid](https://github.com/dfinity/candid) data to a string.

## Install

* Install [Mops](https://j4mwm-bqaaa-aaaam-qajbq-cai.ic0.app/#/docs/install)
* Run `mops add candid_stringify` in your project directory.
* Run `mops add base candid itertools xtended-numbers` to install dependencies.
* Make sure you add mops to your `dfx` file
```
...
  "defaults": {
    "build": {
      "packtool": "mops sources"
    }
  },
...
```

## Usage

```

import C "candid_stringify";

actor {
    
  type ComplexSample = {
    name : Text;
    age : Int;
    owner : Principal;
    address : {
      street : Text;
      phone : ?Text;
      location : {
        state : Text; 
      };
    };
    language : {
      #english : Text;
      #spanish : Text;
      #french : Text;
    };
    music : [MusicTypes];

  };

  type MusicTypes = {
    rock : Bool;
    dance : Text;
  };
    

  public func stringify_record(i : ComplexSample) : async Text {
    var blob = to_candid (i);

    C.stringify(blob, ["name", "age", "owner", "address", "street", "phone", "location", "state", "language", "english","spanish", "french","music", "rock", "dance" ]);
  };
};
```
