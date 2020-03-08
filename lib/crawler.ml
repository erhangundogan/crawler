let version = "0.0.1"

module Parser = struct
  open Soup

  module UrlSet = Set.Make(String)

  let parse_file filename = read_file filename |> parse
  let parse_content content = content |> parse
  let url_addresses soup =
    let rec aux acc = function
    | [] -> acc
    | h :: t -> aux (UrlSet.add (R.attribute "href" h) acc) t in
    aux UrlSet.empty (soup $$ "a[href]" |> to_list)
end

module Io = struct
  let save fname contents =
    Lwt_io.(with_file ~mode:output fname
      (fun channel -> write channel contents))
end

module Http = struct
  open Lwt.Infix
  open Cohttp_lwt
  open Cohttp_lwt_unix

  type t = {
    mutable uri : Uri.t;
    mutable body : string;
    mutable headers : Cohttp.Header.t
  }

  let last = {
    uri = Uri.empty;
    body = "";
    headers = Cohttp.Header.init ()
  }

  let memo uri body headers =
    last.uri <- uri;
    last.body <- body;
    last.headers <- headers

  let is_redirection status =
    Cohttp.Code.(code_of_status status |> is_redirection)

  let get_location headers =
    let location = Cohttp.Header.get headers "location" in
    match location with
    | None -> failwith "Redirect location not specified!"
    | Some s -> s

  let rec fetch uri =
    Client.get uri >>= fun (res, body) ->
      if is_redirection res.status
      then get_location res.headers |> Uri.of_string |> fetch
      else
        Body.to_string body >>= fun body ->
          memo uri body res.headers;
          Lwt.return body

  let get uri =
    if uri = last.uri
    then Lwt.return last.body
    else fetch uri
end
