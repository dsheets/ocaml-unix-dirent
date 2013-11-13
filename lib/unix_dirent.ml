module File_kind = struct
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

  external dt_unknown : unit -> int = "unix_dirent_dt_unknown" "noalloc"
  external dt_fifo    : unit -> int = "unix_dirent_dt_fifo"    "noalloc"
  external dt_chr     : unit -> int = "unix_dirent_dt_chr"     "noalloc"
  external dt_dir     : unit -> int = "unix_dirent_dt_dir"     "noalloc"
  external dt_blk     : unit -> int = "unix_dirent_dt_blk"     "noalloc"
  external dt_reg     : unit -> int = "unix_dirent_dt_reg"     "noalloc"
  external dt_lnk     : unit -> int = "unix_dirent_dt_lnk"     "noalloc"
  external dt_sock    : unit -> int = "unix_dirent_dt_sock"    "noalloc"
  external dt_wht     : unit -> int = "unix_dirent_dt_wht"     "noalloc"

  type defns = {
    dt_unknown : int option;
    dt_fifo    : int option;
    dt_chr     : int option;
    dt_dir     : int option;
    dt_blk     : int option;
    dt_reg     : int option;
    dt_lnk     : int option;
    dt_sock    : int option;
    dt_wht     : int option;
  }

  type index = (int, t) Hashtbl.t
  type host = defns * index

  let to_code ~host = let (defns,_) = host in Unix.(function
    | DT_UNKNOWN -> defns.dt_unknown
    | DT_FIFO    -> defns.dt_fifo
    | DT_CHR     -> defns.dt_chr
    | DT_DIR     -> defns.dt_dir
    | DT_BLK     -> defns.dt_blk
    | DT_REG     -> defns.dt_reg
    | DT_LNK     -> defns.dt_lnk
    | DT_SOCK    -> defns.dt_sock
    | DT_WHT     -> defns.dt_wht
  )

  let index_of_defns defns =
    let open Unix in
    let open Hashtbl in
    let h = create 10 in
    (match defns.dt_unknown with
    | Some x -> replace h x DT_UNKNOWN | None -> ());
    (match defns.dt_fifo with
    | Some x -> replace h x DT_FIFO    | None -> ());
    (match defns.dt_chr with
    | Some x -> replace h x DT_CHR     | None -> ());
    (match defns.dt_dir with
    | Some x -> replace h x DT_DIR     | None -> ());
    (match defns.dt_blk with
    | Some x -> replace h x DT_BLK     | None -> ());
    (match defns.dt_reg with
    | Some x -> replace h x DT_REG     | None -> ());
    (match defns.dt_lnk with
    | Some x -> replace h x DT_LNK     | None -> ());
    (match defns.dt_sock with
    | Some x -> replace h x DT_SOCK    | None -> ());
    (match defns.dt_wht with
    | Some x -> replace h x DT_WHT     | None -> ());
    h

  let host =
    let option f = match f () with -1 -> None | x -> Some x in
    let defns = {
      dt_unknown = option dt_unknown;
      dt_fifo    = option dt_fifo;
      dt_chr     = option dt_chr;
      dt_dir     = option dt_dir;
      dt_blk     = option dt_blk;
      dt_reg     = option dt_reg;
      dt_lnk     = option dt_lnk;
      dt_sock    = option dt_sock;
      dt_wht     = option dt_wht;
    } in
    let index = index_of_defns defns in
    (defns,index)

  let of_code ~host code =
    let (_,index) = host in
    try Some (Hashtbl.find index code)
    with Not_found -> None
end
