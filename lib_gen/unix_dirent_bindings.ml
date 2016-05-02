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

let dir_handle = Ctypes.(
  view
    ~read:(function
      | Some ptr ->
        Some (Unix_representations.dir_handle_of_nativeint
                (raw_address_of_ptr ptr))
      | None -> None
    )
    ~write:(function
      | Some dir ->
        Some (ptr_of_raw_address
                (Unix_representations.nativeint_of_dir_handle dir))
      | None -> None
    )
    (ptr_opt void))

module C(F: Cstubs.FOREIGN) = struct

  let opendir =
    F.foreign "unix_dirent_opendir" (string @-> returning dir_handle)

  let readdir =
    F.foreign "unix_dirent_readdir" (dir_handle @-> returning (ptr_opt dirent))

  let closedir =
    F.foreign "unix_dirent_closedir" (dir_handle @-> returning int)

end
