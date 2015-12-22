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

module Dirent = struct
  type t
end

module C(F: Cstubs.Types.TYPE) = struct

  module File_kind = struct
    let t = F.uint8_t

    let dt_unknown = F.constant "DT_UNKNOWN" t
    let dt_fifo    = F.constant "DT_FIFO" t
    let dt_chr     = F.constant "DT_CHR" t
    let dt_dir     = F.constant "DT_DIR" t
    let dt_blk     = F.constant "DT_BLK" t
    let dt_reg     = F.constant "DT_REG" t
    let dt_lnk     = F.constant "DT_LNK" t
    let dt_sock    = F.constant "DT_SOCK" t
    let dt_wht     = F.constant "DT_WHT" t
  end

  module Dirent = struct
    let t : Dirent.t Ctypes_static.structure F.typ = F.structure "dirent"
    let ( -: ) s x = F.field t s x
    let ino    = "d_ino"    -: F.uint64_t
    (*let off    = "d_off"    -: F.uint64_t*)
    let reclen = "d_reclen" -: F.ushort
    let type_  = "d_type"   -: F.uchar
    let name   = "d_name"   -: F.array 0 F.char
    let () = F.seal t
  end

end
