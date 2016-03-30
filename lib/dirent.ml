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
    dt_unknown : char;
    dt_fifo    : char;
    dt_chr     : char;
    dt_dir     : char;
    dt_blk     : char;
    dt_reg     : char;
    dt_lnk     : char;
    dt_sock    : char;
    dt_wht     : char;
  }

  type index = (char, t) Hashtbl.t

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

  let of_code_exn ~host code =
    let (_,index) = host in
    Hashtbl.find index code

  let of_code ~host code =
    try Some (of_code_exn ~host code)
    with Not_found -> None

  let to_string = function
    | DT_UNKNOWN -> "DT_UNKNOWN"
    | DT_FIFO    -> "DT_FIFO"
    | DT_CHR     -> "DT_CHR"
    | DT_DIR     -> "DT_DIR"
    | DT_BLK     -> "DT_BLK"
    | DT_REG     -> "DT_REG"
    | DT_LNK     -> "DT_LNK"
    | DT_SOCK    -> "DT_SOCK"
    | DT_WHT     -> "DT_WHT"

  (*
  let typ ~host =
    Ctypes.(view ~read:(of_code_exn ~host) ~write:(to_code ~host) char)
   *)

  module Host = struct
    type t = defns * index

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

    let of_defns defns = (defns, index_of_defns defns)

  end
end

module Dirent = struct
  type t = {
    ino  : int64;
    kind : File_kind.t;
    name : string;
  }
end

module Host = struct
  type t = {
    file_kind : File_kind.Host.t;
  }
end
