open Core.Std


let process input =
  try
    let lexbuf = Lexing.from_string input in
    lexbuf.Lexing.lex_curr_p <- Lexing.({
        lexbuf.lex_curr_p with
        pos_fname = "<stdin>";
      });
    let ApiAst.Api (pre, api, post) = ApiPasses.parse_lexbuf lexbuf in
    ApiPasses.all pre api post
  with e ->
    "// Error: " ^ Exn.to_string e ^ "\n"
