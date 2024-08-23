import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";

module {
  public type Item = {
    id: Nat;
    name: Text;
    price: Nat;
    seller: Principal;
  };

  public class Market() {
    private var itemCounter : Nat = 0;
    private let items = HashMap.HashMap<Nat, Item>(10, Nat.equal, func (n: Nat) : Nat32 { Nat32.fromNat(n) });
    private let userItems = HashMap.HashMap<Principal, [Nat]>(10, Principal.equal, Principal.hash);

    public func createItem(caller: Principal, name: Text, price: Nat) : Nat {
      itemCounter += 1;
      let newItem : Item = {
        id = itemCounter;
        name = name;
        price = price;
        seller = caller;
      };
      items.put(itemCounter, newItem);

      switch (userItems.get(caller)) {
        case (null) {
          userItems.put(caller, [itemCounter]);
        };
        case (?userItemIds) {
          let newUserItems = Array.append(userItemIds, [itemCounter]);
          userItems.put(caller, newUserItems);
        };
      };

      itemCounter
    };

    public func getItem(itemId: Nat) : ?Item {
      items.get(itemId)
    };

    public func getUserItems(user: Principal) : [Nat] {
      switch (userItems.get(user)) {
        case (null) { [] };
        case (?userItemIds) { userItemIds };
      }
    };

    public func getAllItems() : [(Nat, Item)] {
      Iter.toArray(items.entries())
    };

    public func removeItem(caller: Principal, itemId: Nat) : Bool {
      switch (items.get(itemId)) {
        case (null) { false };
        case (?item) {
          if (item.seller == caller) {
            items.delete(itemId);
            switch (userItems.get(caller)) {
              case (null) { };
              case (?userItemIds) {
                let updatedItems = Array.filter<Nat>(userItemIds, func (id: Nat) : Bool { id != itemId });
                userItems.put(caller, updatedItems);
              };
            };
            true
          } else {
            false
          }
        };
      }
    };
  };
}