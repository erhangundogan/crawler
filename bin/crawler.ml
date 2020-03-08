open Lwt.Infix

let get_links content =
  Crawler.(
    let soup = Parser.parse_content content in
    let urls = Parser.url_addresses soup in
    let () = Parser.UrlSet.iter (fun i -> print_endline i) urls in
    Printf.printf "Total links count: %d\n" (Parser.UrlSet.cardinal urls)
  )

let request ofile uri =
  Crawler.(
    Http.get uri >>= fun content ->
      match ofile with
      | None -> Lwt.return (get_links content)
      | Some fname -> Io.save fname content >>= fun _ ->
        Lwt.return (get_links content)
  )

let run ofile uri =
  Lwt_main.run (request ofile uri)

open Cmdliner

let uri =
  let doc = "URI/URL to make a request through either HTTP or HTTPS schemes." in
  let loc: Uri.t Arg.converter =
    let parse s =
      try `Ok (Uri.of_string s)
      with Failure _ -> `Error "unable to parse URI" in
    parse, fun ppf p -> Format.fprintf ppf "%s" (Uri.to_string p)
  in
  Arg.(required & pos 0 (some loc) None & info [] ~docv:"URI" ~doc)

let ofile =
  let doc =
    "Save URI content into the file specified. If it's not specified \
     then the file saved into the current directory with the domain name \
     of the URI and '.html' postfix (e.g. www.google.com.html)" in
  Arg.(value & opt (some string) None & info ["o"] ~docv:"FILE" ~doc)

let cmd =
  let doc = "Retrieve a remote URI content details" in
  let man = [
    `S "DESCRIPTION";
    `P "$(tname) fetches the remote $(i,URI) and then parse HTML content. \
        Then extracts anchor elements' href attributes to stdout. \
        The output file for the HTML page can be specified with the \
        $(b,-o) option.";
    `S "BUGS";
    `P "Report then via e-mail to Erhan Gundogan <erhan.gundogan at gmail.com>." ]
  in
  Term.(pure run $ ofile $ uri),
  Term.info "crawler" ~version:Crawler.version ~doc ~man

let () =
  match Term.eval cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
