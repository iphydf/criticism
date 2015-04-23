open Core.Std


let parse input =
  let lexbuf = Lexing.from_string input in

  let state = ApiLexer.state () in
  let api = ApiParser.parse_api (ApiLexer.token state) lexbuf in

  api


let process input =
  try
    let ApiAst.Api (pre, api, post) = parse input in
    ApiPasses.all pre api post
  with e ->
    "// Error: " ^ Exn.to_string e ^ "\n"
