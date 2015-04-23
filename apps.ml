open Core.Std
open Async.Std
open Cohttp_async


let rec apps = [
  "/apidsl", Apidsl.process;
  "/", list_apps;
]

and list_apps body =
  "List of apps:\n" ^ String.concat (List.map ~f:(fun (n, _) -> "  " ^ n ^ "\n") apps)


let process_error path body =
  "Not found: " ^ path ^ "\n"

let process path =
  match List.Assoc.find apps path with
  | Some handler -> handler
  | _ -> process_error path


let start_server port () =
  Server.create ~on_handler_error:`Raise
    (Tcp.on_port port) (fun ~body _ req ->
        match req |> Cohttp.Request.meth with
        | `POST | `GET ->
            Body.to_string body >>= fun body ->
            let app = Uri.path @@ Cohttp.Request.uri req in
            let body = process app body |> Body.of_string in
            Server.respond ~body `OK
        | _ ->
            Server.respond `Method_not_allowed
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
