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
  type t
  let t : t structure typ = structure "Dirent"
  let ( -: ) s x = field t s x
  let ino    = "ino"    -: ino_t
  let off    = "off"    -: off_t
  let reclen = "reclen" -: ushort
  let type_  = "type"   -: uchar
  let name   = "name"   -: array 0 char
  let () = seal t
end

type dir_handle = unit ptr
let dir_handle : dir_handle typ = ptr void

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
    | Some ent -> !@ (allocate Dirent.t (!@ ent))
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
