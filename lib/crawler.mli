val version : string
module Parser :
  sig
    module UrlSet :
      sig
        type elt = String.t
        type t = Stdlib__set.Make(String).t
        val empty : t
        val add : elt -> t -> t
        val iter : (elt -> unit) -> t -> unit
        val cardinal : t -> int
      end
    val parse_file : string -> Soup.soup Soup.node
    val parse_content : string -> Soup.soup Soup.node
    val url_addresses : 'a Soup.node -> UrlSet.t
  end
module Io :
  sig
    val save : Lwt_io.file_name -> string -> unit Lwt.t
  end
module Http :
  sig
    type t = {
      mutable uri : Uri.t;
      mutable body : string;
      mutable headers : Cohttp.Header.t;
    }
    val last : t
    val get : Uri.t -> string Lwt.t
  end
