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

  val of_file_kind : Unix.file_kind -> t

  val to_code : host:host -> t -> int
  val of_code : host:host -> int -> t option
end

