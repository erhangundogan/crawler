let save_source file contents =
  Lwt_io.(with_file ~mode:output file
    (fun ch -> write ch contents))

let write_channel ch l =
  Lwt_list.iter_p (fun i -> Lwt_io.fprintl ch i) l

let save_urls file urls =
  Lwt_io.(with_file ~mode:output file
    (fun ch -> write_channel ch (Parser.UrlSet.elements urls)))
