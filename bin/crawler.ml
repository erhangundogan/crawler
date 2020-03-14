open Lwt.Infix
open Crawler
open Parser

let print_urls urls =
  UrlSet.iter (fun i -> print_endline i) urls

let get_urls_with_base uri content =
  content
  |> parse_content
  |> extract_urls
  |> normalise_urls uri
  |> validate_urls

let save_urls urls_file urls =
  if Option.is_some urls_file
  then Io.save_urls (Option.get urls_file) urls >>= fun _ ->
    Logs.info (fun f -> f "URLs saved to a file: %s" (Option.get urls_file));
    Lwt.return ()
  else Lwt.return ()

let save_source source_file content =
  if Option.is_some source_file
  then Io.save_source (Option.get source_file) content >>= fun _ ->
    Logs.info (fun f -> f "Page source saved to a file: %s" (Option.get source_file));
    Lwt.return ()
  else Lwt.return ()

let request source_file urls_file is_print uri =
  Http.get uri >>= fun content ->
    let urls = get_urls_with_base uri content in
    Logs.info (fun f -> f "Total %d URL addresses extracted" (UrlSet.cardinal urls));
    save_source source_file content >>= fun _ ->
    save_urls urls_file urls >>= fun _ ->
    Lwt.return @@ if is_print then print_urls urls else ()

let run arg_source_file arg_urls_file arg_print_urls arg_uri =
  Fmt_tty.setup_std_outputs ();
  Logs.set_level @@ Some Logs.Info;
  Logs.set_reporter (Logs_fmt.reporter ());
  Lwt_main.run (request arg_source_file arg_urls_file arg_print_urls arg_uri)

open Cmdliner

let arg_uri =
  let doc = "URI/URL to make a request through either HTTP or HTTPS schemes." in
  let loc: Uri.t Arg.converter =
    let parse s =
      try `Ok (Uri.of_string s)
      with Failure _ -> `Error "unable to parse URI" in
    parse, fun ppf p -> Format.fprintf ppf "%s" (Uri.to_string p)
  in
  Arg.(required & pos 0 (some loc) None & info [] ~docv:"URI" ~doc)

let arg_print_urls =
  let doc =
    "Print out results (URLs) to the console" in
  Arg.(value & flag & info ["p"] ~doc)

let arg_source_file =
  let doc =
    "Save URI content into the file specified" in
  Arg.(value & opt (some string) None & info ["s"; "source"] ~docv:"FILE" ~doc)

let arg_urls_file =
  let doc =
    "Save results (URLs) into the file specified" in
  Arg.(value & opt (some string) None & info ["u"; "urls"] ~docv:"FILE" ~doc)

let cmd =
  let doc = "Retrieve a remote URI content and extract URLs" in
  let man = [
    `S "DESCRIPTION";
    `P "$(tname) fetches the remote $(i,URI) and then parse HTML content. \
        Then extracts anchor elements' href attributes. \
        The output file for the HTML content can be specified with the \
        $(b,-s) option and the output file for the URLs can be \
        specified with the $(b,-u) option.";
    `S "BUGS";
    `P "Report then via e-mail to Erhan Gundogan <erhan.gundogan at gmail.com>." ]
  in
  Term.(pure run $ arg_source_file $ arg_urls_file $ arg_print_urls $ arg_uri),
  Term.info "crawler" ~version:Crawler.Version.v ~doc ~man

let () =
  match Term.eval cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
