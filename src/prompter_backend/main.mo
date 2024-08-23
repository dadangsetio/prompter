import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Types "Types";
import JSON "mo:serde/JSON";
import GPTResponse "GPTResponse";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Secret "Env";
import Principal "mo:base/Principal";
import Array "mo:base/Array";

actor ChatBot {
  type ChatRecord = {
    prompt: Text;
    response: Text;
  };

  type TopicNFT = {
    owner: Principal;
    id: Nat;
    title: Text;
    messages: Buffer.Buffer<ChatRecord>;
  };

  type UserData = {
    topics: [Nat];
  };

  func hashNat(n: Nat) : Nat32 {
    let text = Int.toText(n);
    let hash = Text.hash(text);
    hash
  };

  let ic : Types.IC = actor ("aaaaa-aa");
  var nftCounter : Nat = 0;
  let nfts = HashMap.HashMap<Nat, TopicNFT>(10, Nat.equal, hashNat);
  let users = HashMap.HashMap<Principal, UserData>(10, Principal.equal, Principal.hash);

  public shared (msg) func whoami() : async Principal {
    msg.caller
  };

  public func helloworld() : async Text {
    return "Halo dunia!";
  };

  public shared(msg) func createTopicNFT(title : Text) : async Nat {
    let caller = msg.caller;
    nftCounter += 1;
    let newNFT : TopicNFT = {
      owner = caller;
      id = nftCounter;
      title = title;
      messages = Buffer.Buffer<ChatRecord>(0);
    };
    nfts.put(nftCounter, newNFT);

    switch (users.get(caller)) {
      case (null) {
        users.put(caller, { topics = [nftCounter] });
      };
      case (?userData) {
        let newTopics = Array.append(userData.topics, [nftCounter]);
        users.put(caller, { topics = newTopics });
      };
    };

    nftCounter
  };

  public query func getNFT(id: Nat) : async ?{
    owner: Principal;
    id: Nat;
    title: Text;
    messages: [ChatRecord];
  } {
    switch (nfts.get(id)) {
      case (null) { null };
      case (?nft) {
        ?{
          owner = nft.owner;
          id = nft.id;
          title = nft.title;
          messages = Buffer.toArray(nft.messages);
        }
      };
    }
  };

  public shared(msg) func transferNFT(id: Nat, to: Principal) : async Bool {
    let caller = msg.caller;
    switch (nfts.get(id)) {
      case (null) { false };
      case (?nft) {
        if (nft.owner == caller) {
          let updatedNFT : TopicNFT = {
            owner = to;
            id = nft.id;
            title = nft.title;
            messages = nft.messages;
          };
          nfts.put(id, updatedNFT);

          switch (users.get(caller)) {
            case (null) { };
            case (?userData) {
              let updatedTopics = Array.filter<Nat>(userData.topics, func (topicId: Nat) : Bool { topicId != id });
              users.put(caller, { topics = updatedTopics });
            };
          };

          switch (users.get(to)) {
            case (null) {
              users.put(to, { topics = [id] });
            };
            case (?userData) {
              let newTopics = Array.append(userData.topics, [id]);
              users.put(to, { topics = newTopics });
            };
          };

          true
        } else {
          false
        }
      };
    }
  };

  public shared(msg) func sendPrompt(nftId : Nat, prompt : Text) : async Text {
    let caller = msg.caller;
    
    switch (nfts.get(nftId)) {
      case (null) { return "NFT not found."; };
      case (?nft) {
        if (nft.owner != caller) {
          return "You don't own this NFT.";
        };
      };
    };

    let apiKey = Secret.SECRET_GPT_KEY;
    let url = "https://api.openai.com/v1/chat/completions";
    
    let requestHeaders = [
      { name = "Content-Type"; value = "application/json" },
      { name = "Authorization"; value = "Bearer " # apiKey }
    ];

    let requestBody = "{\"model\": \"gpt-3.5-turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"" # prompt # "\"}]}";

    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let request : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null;
      headers = requestHeaders;
      body = ?Blob.toArray(Text.encodeUtf8(requestBody));
      method = #post;
      transform = ?transform_context;
    };

    Cycles.add(100_000_000_000); 
    try {
      let response = await ic.http_request(request);

      switch (Text.decodeUtf8(Blob.fromArray(response.body))) {
        case (null) { "Failed to decode response." };
        case (?responseText) {
          let decodedResponse = decodeResponse(responseText);
          let newRecord : ChatRecord = {
            prompt = prompt;
            response = decodedResponse;
          };
          
          switch (nfts.get(nftId)) {
            case (null) { "NFT not found." };
            case (?nft) {
              nft.messages.add(newRecord);
              nfts.put(nftId, nft);
              decodedResponse
            };
          };
        };
      };
    } catch (error) {
      Debug.print("Error: " # Error.message(error));
      "An error occurred while contacting the API."
    };
  };

  public shared(msg) func getChatHistory(nftId : Nat) : async ?[ChatRecord] {
    let caller = msg.caller;
    
    switch (nfts.get(nftId)) {
      case (null) { return null; };
      case (?nft) {
        if (nft.owner != caller) {
          return null;
        };
        ?Buffer.toArray(nft.messages)
      };
    };
  };

  public shared(msg) func getUserNFTs() : async [Nat] {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) { [] };
      case (?userData) { userData.topics };
    };
  };

  public query func getAllTopics() : async [(Nat, Text)] {
    Iter.toArray(Iter.map<(Nat, TopicNFT), (Nat, Text)>(
      nfts.entries(),
      func ((id, nft) : (Nat, TopicNFT)) : (Nat, Text) {
        (id, nft.title)
      }
    ))
  };

  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        { name = "Content-Security-Policy"; value = "default-src 'self'" },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        { name = "Strict-Transport-Security"; value = "max-age=63072000" },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  func decodeResponse(responseText : Text) : Text {
    let parseResult = JSON.fromText(responseText, null);
    switch (parseResult) {
      case (#err(err)) {
        Debug.print("Error parsing JSON: " # err);
        "Error parsing JSON"
      };
      case (#ok(jsonValue)) {
        let gptResponse : ?GPTResponse.ChatGPTResponse = from_candid(jsonValue);
        switch (gptResponse) {
          case (null) { "Failed to convert JSON to ChatGPTResponse type." };
          case (?response) {
            switch (response.choices[0].message.content) {
              case (?content) { content };
              case (null) { "No content in the response." };
            };
          };
        };
      };
    };
  };
};