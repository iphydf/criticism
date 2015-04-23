open Core.Std
open Async.Std
open Cohttp_async

let apigen input =
  input ^ " hehe"


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
