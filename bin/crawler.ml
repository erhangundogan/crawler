open Lwt.Infix
open Crawler
open Parser

let print_urls urls =
  urls
  |> UrlSet.iter (fun i -> print_endline i)
  |> fun _ -> Printf.printf "Total links count: %d\n" (UrlSet.cardinal urls)

let get_urls_with_base uri content =
  content
  |> parse_content
  |> extract_urls
  |> normalise_urls uri
  |> validate_urls

let save_urls data_file urls =
  if Option.is_some data_file
  then Io.save_urls (Option.get data_file) urls
  else Lwt.return ()

let save_source source_file content =
  if Option.is_some source_file
  then Io.save_source (Option.get source_file) content
  else Lwt.return ()

let request source_file data_file uri =
  Http.get uri >>= fun content ->
    let urls = get_urls_with_base uri content in
    save_source source_file content >>= fun _ ->
    save_urls data_file urls >>= fun _ ->
    Lwt.return @@ print_urls urls

let run source_file data_file uri =
  Lwt_main.run (request source_file data_file uri)

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

let source_file =
  let doc =
    "Save URI content into the file specified." in
  Arg.(value & opt (some string) None & info ["s"; "source"] ~docv:"FILE" ~doc)

let data_file =
  let doc =
    "Save data content (details) into the file specified" in
  Arg.(value & opt (some string) None & info ["d"; "data"] ~docv:"FILE" ~doc)

let cmd =
  let doc = "Retrieve a remote URI content details" in
  let man = [
    `S "DESCRIPTION";
    `P "$(tname) fetches the remote $(i,URI) and then parse HTML content. \
        Then extracts anchor elements' href attributes to stdout. \
        The output file for the HTML page can be specified with the \
        $(b,-s) option and the output file for the page links can be \
        specified with the $(b,-d) option\ ";
    `S "BUGS";
    `P "Report then via e-mail to Erhan Gundogan <erhan.gundogan at gmail.com>." ]
  in
  Term.(pure run $ source_file $ data_file $ uri),
  Term.info "crawler" ~version:Crawler.Version.v ~doc ~man

let () =
  match Term.eval cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
