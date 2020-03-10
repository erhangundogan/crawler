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
