(lang dune 2.3)
(name crawler)
(version 0.2.3)
(generate_opam_files true)

(source (github erhangundogan/crawler))
(license MIT)
(authors "Erhan Gundogan <erhan.gundogan@gmail.com>")
(maintainers "erhan.gundogan@gmail.com")

(package
  (name crawler)
  (synopsis "Retrieve URI resources and extract details")
  (description "
This library is used to retrieve URI resources and
extracts some details with HTML parser.")
  (depends
    (ocaml (>= 4.08.0))
    lwt
    cohttp-lwt
    cohttp-lwt-unix
    lambdasoup
    cmdliner
  ))
