let save fname contents =
  Lwt_io.(with_file ~mode:output fname
    (fun channel -> write channel contents))
