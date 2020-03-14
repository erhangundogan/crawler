# Crawler

Crawl a website to extract some data.
Currently retrieves the HTML content and extracts anchor links.
All URLs transform into the absolute URL and multiples are filtered.

Install
=======

```bash
$ git clone git@github.com:erhangundogan/crawler.git
$ cd crawler
$ dune build
```

Run
===

Simple usage is command, -p flag (print out results to console) and URL address:
 
```bash
$ ./_build/default/bin/crawler.exe -p "https://www.google.com"
crawler.exe: [INFO] Fetching: https://www.google.com
crawler.exe: [INFO] Total 18 URL addresses extracted
https://drive.google.com/?tab=wo
https://mail.google.com/mail/?tab=wm
...
```

Please check out the man page with `--help` for usage.

```bash
$ ./_build/default/bin/crawler.exe --help
```
