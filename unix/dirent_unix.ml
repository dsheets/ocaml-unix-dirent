(*
 * Copyright (c) 2014-2015 David Sheets <sheets@alum.mit.edu>
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

module Type = Unix_dirent_types.C(Unix_dirent_types_detected)
module C = Unix_dirent_bindings.C(Unix_dirent_generated)

module File_kind = struct
  let host =
    let char_of_uint8 i = char_of_int (Unsigned.UInt8.to_int i) in
    let defns = Dirent.File_kind.(Type.File_kind.({
      dt_unknown = char_of_uint8 dt_unknown;
      dt_fifo    = char_of_uint8 dt_fifo;
      dt_chr     = char_of_uint8 dt_chr;
      dt_dir     = char_of_uint8 dt_dir;
      dt_blk     = char_of_uint8 dt_blk;
      dt_reg     = char_of_uint8 dt_reg;
      dt_lnk     = char_of_uint8 dt_lnk;
      dt_sock    = char_of_uint8 dt_sock;
      dt_wht     = char_of_uint8 dt_wht;
    })) in
    Dirent.File_kind.Host.of_defns defns
end

let opendir name =
  match C.opendir name with
    Some h, _ -> h
  | _, errno -> Errno_unix.raise_errno ~call:"closedir" errno

let readdir dirh =
  match C.readdir (Some dirh) with
  | None, errno when errno = Signed.SInt.zero -> raise End_of_file
  | None, errno -> Errno_unix.raise_errno ~call:"readdir" errno
  | Some t, _ ->
    let open Ctypes in
    let open Unsigned in
    let ent = !@ t in
    let kind_code = char_of_int (UChar.to_int (getf ent Type.Dirent.type_)) in
    let host = File_kind.host in
    let kind_opt = Dirent.File_kind.of_code ~host kind_code in
    let kind = match kind_opt with
      | None -> Dirent.File_kind.DT_UNKNOWN
      | Some kind -> kind
    in
    Dirent.Dirent.(Type.Dirent.({
      ino  = UInt64.to_int64 (getf ent ino);
      kind;
      name = coerce (ptr char) string (CArray.start (getf ent name));
    }))

let closedir dirh =
  match C.closedir (Some dirh) with
    0, _ -> ()
  | _, errno -> Errno_unix.raise_errno ~call:"closedir" errno

let host = { Dirent.Host.file_kind = File_kind.host }
