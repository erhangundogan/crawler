open Soup

module UrlSet = Set.Make(String)

let parse_file filename = read_file filename |> parse
let parse_content content = content |> parse
let url_addresses soup =
  let rec aux acc = function
  | [] -> acc
  | h :: t -> aux (UrlSet.add (R.attribute "href" h) acc) t in
  aux UrlSet.empty (soup $$ "a[href]" |> to_list)

