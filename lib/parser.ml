open Soup

module UrlSet = Set.Make(String)

let parse_file filename = read_file filename |> parse

let parse_content content = content |> parse

let extract_urls soup =
  let rec aux acc = function
  | [] -> acc
  | h :: t -> aux (UrlSet.add (R.attribute "href" h) acc) t in
  aux UrlSet.empty (soup $$ "a[href]" |> to_list)

let validate_urls urls =
  UrlSet.filter (fun i ->
    let uri = Uri.of_string i in
    let scheme = Option.get @@ Uri.scheme uri in
    scheme = "http" || scheme = "https"
  ) urls

let normalise_urls base_uri url_set = match Uri.scheme base_uri with
  | None -> failwith "Please define base_uri arg"
  | Some _ ->
    let replace uri = Uri.with_uri uri
      ~scheme:(Uri.scheme base_uri)
      ~host:(Uri.host base_uri)
      ~fragment:None
      ~query:None
      in
    let minify uri = Uri.with_uri uri
      ~fragment:None
      ~query:None
    in
    UrlSet.map (fun i ->
      let i_uri = Uri.of_string i in
      let scheme = Uri.scheme i_uri in
      if Option.is_none scheme
      then Uri.to_string (replace i_uri)
      else Uri.to_string (minify i_uri)
    ) url_set
