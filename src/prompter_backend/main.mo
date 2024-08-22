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
import Option "mo:base/Option";

actor ChatBot {
  type ChatRecord = {
    prompt: Text;
    response: Text;
  };

  type Topic = {
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
  var topicCounter : Nat = 0;
  let topics = HashMap.HashMap<Nat, Topic>(10, Nat.equal, hashNat);
  let users = HashMap.HashMap<Principal, UserData>(10, Principal.equal, Principal.hash);

  public shared (msg) func whoami() : async Principal {
    msg.caller
  };

  public shared(msg) func createTopic(title : Text) : async Nat {
    let caller = msg.caller;
    topicCounter += 1;
    let newTopic : Topic = {
      id = topicCounter;
      title = title;
      messages = Buffer.Buffer<ChatRecord>(0);
    };
    topics.put(topicCounter, newTopic);

    // Menambahkan topik ke data pengguna
    switch (users.get(caller)) {
      case (null) {
        users.put(caller, { topics = [topicCounter] });
      };
      case (?userData) {
        let newTopics = Array.append(userData.topics, [topicCounter]);
        users.put(caller, { topics = newTopics });
      };
    };

    topicCounter
  };

  public shared(msg) func sendPrompt(topicId : Nat, prompt : Text) : async Text {
    let caller = msg.caller;
    
    // Memeriksa apakah pengguna memiliki akses ke topik ini
    switch (users.get(caller)) {
      case (null) { return "Pengguna tidak ditemukan."; };
      case (?userData) {
        switch (Array.find<Nat>(userData.topics, func (id: Nat) : Bool { id == topicId })) {
          case (null) { return "Anda tidak memiliki akses ke topik ini."; };
          case (_) { };
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
        case (null) { "Gagal mendekode respons." };
        case (?responseText) {
          let decodedResponse = decodeResponse(responseText);
          let newRecord : ChatRecord = {
            prompt = prompt;
            response = decodedResponse;
          };
          
          switch (topics.get(topicId)) {
            case (null) { "Topik tidak ditemukan." };
            case (?topic) {
              topic.messages.add(newRecord);
              topics.put(topicId, topic);
              decodedResponse
            };
          };
        };
      };
    } catch (error) {
      Debug.print("Error: " # Error.message(error));
      "Terjadi kesalahan saat menghubungi API."
    };
  };

  public shared(msg) func getChatHistory(topicId : Nat) : async ?[ChatRecord] {
    let caller = msg.caller;
    
    // Memeriksa apakah pengguna memiliki akses ke topik ini
    switch (users.get(caller)) {
      case (null) { return null; };
      case (?userData) {
        if (not Option.isSome(Array.find<Nat>(userData.topics, func (id: Nat) : Bool { id == topicId }))) {
          return null;
        };
      };
    };

    switch (topics.get(topicId)) {
      case (null) { null };
      case (?topic) { ?Buffer.toArray(topic.messages) };
    };
  };

  public shared(msg) func getUserTopics() : async [Nat] {
    let caller = msg.caller;
    switch (users.get(caller)) {
      case (null) { [] };
      case (?userData) { userData.topics };
    };
  };

  public query func getAllTopics() : async [(Nat, Text)] {
    Iter.toArray(Iter.map<(Nat, Topic), (Nat, Text)>(
      topics.entries(),
      func ((id, topic) : (Nat, Topic)) : (Nat, Text) {
        (id, topic.title)
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
          case (null) { "Gagal mengonversi JSON ke tipe ChatGPTResponse." };
          case (?response) {
            switch (response.choices[0].message.content) {
              case (?content) { content };
              case (null) { "Tidak ada konten dalam respons." };
            };
          };
        };
      };
    };
  };
};