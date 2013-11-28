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
    dt_unknown : int;
    dt_fifo    : int;
    dt_chr     : int;
    dt_dir     : int;
    dt_blk     : int;
    dt_reg     : int;
    dt_lnk     : int;
    dt_sock    : int;
    dt_wht     : int;
  }

  type index = (int, t) Hashtbl.t
  type host = defns * index

  let of_file_kind = Unix.(function
    | S_REG  -> DT_REG
    | S_DIR  -> DT_DIR
    | S_CHR  -> DT_CHR
    | S_BLK  -> DT_BLK
    | S_LNK  -> DT_LNK
    | S_FIFO -> DT_FIFO
    | S_SOCK -> DT_SOCK
  )

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
    replace h defns.dt_unknown DT_UNKNOWN;
    replace h defns.dt_fifo    DT_FIFO;
    replace h defns.dt_chr     DT_CHR;
    replace h defns.dt_dir     DT_DIR;
    replace h defns.dt_blk     DT_BLK;
    replace h defns.dt_reg     DT_REG;
    replace h defns.dt_lnk     DT_LNK;
    replace h defns.dt_sock    DT_SOCK;
    replace h defns.dt_wht     DT_WHT;
    h

  let host =
    let defns = {
      dt_unknown = dt_unknown ();
      dt_fifo    = dt_fifo ();
      dt_chr     = dt_chr ();
      dt_dir     = dt_dir ();
      dt_blk     = dt_blk ();
      dt_reg     = dt_reg ();
      dt_lnk     = dt_lnk ();
      dt_sock    = dt_sock ();
      dt_wht     = dt_wht ();
    } in
    let index = index_of_defns defns in
    (defns,index)

  let of_code ~host code =
    let (_,index) = host in
    try Some (Hashtbl.find index code)
    with Not_found -> None
end
