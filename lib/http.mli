type t = {
  mutable uri : Uri.t;
  mutable body : string;
  mutable headers : Cohttp.Header.t;
}
val last : t
val get : Uri.t -> string Lwt.t
