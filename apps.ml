open Core.Std
open Async.Std
open Cohttp_async

let parse input =
  let lexbuf = Lexing.from_string input in

  let state = ApiLexer.state () in
  let api = ApiParser.parse_api (ApiLexer.token state) lexbuf in

  api


let apigen input =
  try
    let ApiAst.Api (pre, api, post) = parse input in
    ApiPasses.all pre api post
  with e ->
    "// Error: " ^ Exn.to_string e ^ "\n"


let start_server port () =
  Server.create ~on_handler_error:`Raise
    (Tcp.on_port port) (fun ~body _ req ->
        match req |> Cohttp.Request.meth with
        | `POST ->
          let body = Body.map body apigen in
          Server.respond ~body `OK
        | _ -> Server.respond `Method_not_allowed
      )
  >>= fun _ -> Deferred.never ()


let () =
  Command.async_basic
    ~summary:"Simple http server that ouputs body of POST's"
    Command.Spec.(empty +>
                  flag "-p" (optional_with_default 8080 int)
                    ~doc:"int Source port to listen on"
                 ) start_server
  |> Command.run
