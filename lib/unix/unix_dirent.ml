(*
 * Copyright (c) 2014 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

module File_kind = struct
  include Unix_dirent_private.File_kind

  external dt_unknown : unit -> char = "unix_dirent_dt_unknown" "noalloc"
  external dt_fifo    : unit -> char = "unix_dirent_dt_fifo"    "noalloc"
  external dt_chr     : unit -> char = "unix_dirent_dt_chr"     "noalloc"
  external dt_dir     : unit -> char = "unix_dirent_dt_dir"     "noalloc"
  external dt_blk     : unit -> char = "unix_dirent_dt_blk"     "noalloc"
  external dt_reg     : unit -> char = "unix_dirent_dt_reg"     "noalloc"
  external dt_lnk     : unit -> char = "unix_dirent_dt_lnk"     "noalloc"
  external dt_sock    : unit -> char = "unix_dirent_dt_sock"    "noalloc"
  external dt_wht     : unit -> char = "unix_dirent_dt_wht"     "noalloc"

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

  let of_file_kind = Unix.(function
    | S_REG  -> DT_REG
    | S_DIR  -> DT_DIR
    | S_CHR  -> DT_CHR
    | S_BLK  -> DT_BLK
    | S_LNK  -> DT_LNK
    | S_FIFO -> DT_FIFO
    | S_SOCK -> DT_SOCK
  )

  let to_file_kind = Unix.(function
    | DT_REG  -> Some S_REG
    | DT_DIR  -> Some S_DIR
    | DT_CHR  -> Some S_CHR
    | DT_BLK  -> Some S_BLK
    | DT_LNK  -> Some S_LNK
    | DT_FIFO -> Some S_FIFO
    | DT_SOCK -> Some S_SOCK
    | DT_WHT | DT_UNKNOWN -> None
  )
end

type host = {
  file_kind : File_kind.host;
} with sexp

let host = {
  file_kind = File_kind.host;
}


open Ctypes
open Foreign
open Unsigned
open PosixTypes

module Dirent = struct
  type t = {
    ino  : int64;
    off  : int64;
    kind : File_kind.t;
    name : string;
  }

  let t : t structure typ = structure "Dirent"
  let ( -: ) s x = field t s x
  let ino    = "ino"    -: ino_t
  let off    = "off"    -: off_t
  let reclen = "reclen" -: ushort
  let type_  = "type"   -: File_kind.(t ~host)
  let name   = "name"   -: array 0 char
  let () = seal t
end

type dir_handle = Unix.dir_handle
(* TODO: review *)
let dir_handle = Ctypes.(
  view
    ~read:(fun ptr ->
      let addr = raw_address_of_ptr ptr in
      let dh = Obj.(new_block abstract_tag 1) in
      Obj.(set_field dh 0 (field (repr addr) 1));
      (Obj.obj dh : dir_handle)
    )
    ~write:(fun dir ->
      let addr = 0L in
      Obj.(set_field (repr addr) 1 (field (repr dir) 0));
      ptr_of_raw_address addr
    )
    (ptr void))

let local ?check_errno addr typ =
  coerce (ptr void) (funptr ?check_errno typ) (ptr_of_raw_address addr)

external unix_dirent_opendir_ptr : unit -> int64 = "unix_dirent_opendir_ptr"

let opendir =
  let c = local ~check_errno:true (unix_dirent_opendir_ptr ())
    (string @-> returning dir_handle)
  in
  fun name ->
    try c name
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"opendir",name))

external unix_dirent_readdir_ptr : unit -> int64 = "unix_dirent_readdir_ptr"

let readdir =
  let c = local ~check_errno:true (unix_dirent_readdir_ptr ())
    (dir_handle @-> returning (ptr_opt Dirent.t))
  in
  fun dirh ->
    try (match c dirh with
    | Some t -> let ent = !@ t in Ctypes.(Dirent.({
      ino  = UInt64.to_int64 (coerce ino_t uint64_t (getf ent ino));
      off  = coerce off_t int64_t (getf ent off);
      kind = getf ent type_;
      name = coerce (ptr char) string (CArray.start (getf ent name));
    }))
    | None -> raise End_of_file
    ) with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"readdir",""))

external unix_dirent_closedir_ptr : unit -> int64 = "unix_dirent_closedir_ptr"

let closedir =
  let c = local ~check_errno:true (unix_dirent_closedir_ptr ())
    (dir_handle @-> returning int)
  in
  fun dirh ->
    try ignore (c dirh)
    with Unix.Unix_error(e,_,_) -> raise (Unix.Unix_error (e,"closedir",""))
