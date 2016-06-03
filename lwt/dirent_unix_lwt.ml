(*
 * Copyright (c) 2016 Jeremy Yallop <yallop@docker.com>
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

module Generated = Unix_dirent_lwt_generated
module C = Unix_dirent_bindings.C(Generated)
module Type = Unix_dirent_types.C(Unix_dirent_types_detected)
open Lwt.Infix

let lwt_raise_errno_error ~call ~label code =
  Lwt.fail Errno.(Error { errno = of_code ~host:Errno_unix.host code; call; label; })

let kind_of_code kind_code =
  match Dirent.File_kind.of_code ~host:Dirent_unix.File_kind.host kind_code with
  | None -> Dirent.File_kind.DT_UNKNOWN
  | Some kind -> kind

let readdir handle =
  (C.readdir (Some handle)).Generated.lwt >>= function
    None, 0 -> Lwt.fail End_of_file
  | None, errno -> lwt_raise_errno_error ~call:"readdir" errno
                     ~label:(Nativeint.to_string
                               (Unix_representations.nativeint_of_dir_handle handle))
  | Some t, _ -> let open Ctypes in
    Lwt.return 
      Dirent.Dirent.{
        ino = Unsigned.UInt64.to_int64 (getf (!@ t) Type.Dirent.ino);
        kind = kind_of_code (char_of_int (Unsigned.UChar.to_int (getf (!@ t) Type.Dirent.type_)));
        name = coerce (ptr char) string (CArray.start (getf (!@ t) Type.Dirent.name));
      }

let closedir handle =
  (C.closedir (Some handle)).Generated.lwt >>= function
    0, _ -> Lwt.return_unit
  | _, errno -> lwt_raise_errno_error ~call:"closedir" errno
                  ~label:(Nativeint.to_string
                            (Unix_representations.nativeint_of_dir_handle handle))

let opendir path =
  (C.opendir path).Generated.lwt >>= function
    None, errno -> lwt_raise_errno_error ~call:"opendir" ~label:path errno
  | Some handle, _ -> Lwt.return handle
