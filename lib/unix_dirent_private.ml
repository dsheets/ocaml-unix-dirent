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

  let of_code ~host code =
    let (_,index) = host in
    try Some (Hashtbl.find index code)
    with Not_found -> None
end
