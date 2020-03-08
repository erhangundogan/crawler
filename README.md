# Crawler

Crawl a website to extract some data.
Currently retrieves the HTML content and extracts anchor links. 

Build
=====

```bash
$ dune build
```

Run
===

Simple usage is command and an URI argument:
 
```bash
$ crawler "https://www.google.com"
```

Please check out the man page with `--help` for usage.

```bash
$ crawler --help
```
