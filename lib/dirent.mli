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

  module Host : sig
    type t

    val of_defns : defns -> t
    val to_defns : t -> defns
  end

  val to_code     : host:Host.t -> t -> char
  val of_code_exn : host:Host.t -> char -> t
  val of_code     : host:Host.t -> char -> t option

  val to_string : t -> string
  val of_string : string -> t option
end

module Dirent : sig
  type t = {
    ino  : int64;
    kind : File_kind.t;
    name : string;
  }
end

module Host : sig
  type t = {
    file_kind : File_kind.Host.t;
  }
end
