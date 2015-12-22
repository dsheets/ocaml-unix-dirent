(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
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

open Ctypes

module Types = Unix_dirent_types.C(Unix_dirent_types_detected)

let dirent = Types.Dirent.t

(* TODO: review *)
let dir_handle = Ctypes.(
  view
    ~read:(fun ptr ->
      let addr = raw_address_of_ptr ptr in
      let dh = Obj.(new_block abstract_tag 1) in
      Obj.(set_field dh 0 (field (repr addr) 1));
      (Obj.obj dh : Unix.dir_handle)
    )
    ~write:(fun dir ->
      let addr = Nativeint.zero in
      Obj.(set_field (repr addr) 1 (field (repr dir) 0));
      ptr_of_raw_address addr
    )
    (ptr void))

module C(F: Cstubs.FOREIGN) = struct

  let opendir =
    F.foreign "unix_dirent_opendir" (string @-> returning dir_handle)

  let readdir =
    F.foreign "unix_dirent_readdir" (dir_handle @-> returning (ptr_opt dirent))

  let closedir =
    F.foreign "unix_dirent_closedir" (dir_handle @-> returning int)

end
