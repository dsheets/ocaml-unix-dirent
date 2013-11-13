module File_kind : sig
  type t =
  | DT_UNKNOWN
  | DT_FIFO
  | DT_CHR
  | DT_DIR
  | DT_BLK
  | DT_REG
  | DT_LNK
  | DT_SOCK
  | DT_WHT

  type host

  val host : host

  val to_code : host:host -> t -> int option
  val of_code : host:host -> int -> t option
end

