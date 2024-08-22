module {
  public type ChatGPTResponse = {
    id : Text;
    created : Nat;
    model : Text;
    choices : [Choice];
    usage : Usage;
    system_fingerprint : ?Text;
  };

  public type Choice = {
    index : Nat;
    message : Message;
    logprobs : ?Any;
    finish_reason : Text;
  };

  public type Message = {
    role : Text;
    content : ?Text;
    refusal : ?Text;
  };

  public type Usage = {
    prompt_tokens : Nat;
    completion_tokens : Nat;
    total_tokens : Nat;
  };
}