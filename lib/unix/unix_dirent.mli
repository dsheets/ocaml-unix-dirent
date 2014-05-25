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
  include module type of Unix_dirent_common.File_kind

  val host : host

  val of_file_kind : Unix.file_kind -> t
  val to_file_kind : t -> Unix.file_kind option
end

module Dirent : sig
  type t = {
    ino  : int64;
    off  : int64;
    kind : File_kind.t;
    name : string;
  }
end

type host = {
  file_kind : File_kind.host;
}
val host : host

val sexp_of_host : host -> Sexplib.Sexp.t
val host_of_sexp : Sexplib.Sexp.t -> host

type dir_handle = Unix.dir_handle
val dir_handle : dir_handle Ctypes.typ

val opendir : string -> dir_handle

val readdir : dir_handle -> Dirent.t

val closedir : dir_handle -> unit
