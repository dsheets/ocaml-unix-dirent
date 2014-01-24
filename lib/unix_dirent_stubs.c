/*
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
 */

#include <dirent.h>
#include <caml/mlvalues.h>

#ifndef DT_UNKNOWN
#error "unix_dirent_stubs.c: DT_UNKNOWN macro not found"
#endif
#ifndef DT_FIFO
#error "unix_dirent_stubs.c: DT_FIFO macro not found"
#endif
#ifndef DT_CHR
#error "unix_dirent_stubs.c: DT_CHR macro not found"
#endif
#ifndef DT_DIR
#error "unix_dirent_stubs.c: DT_DIR macro not found"
#endif
#ifndef DT_BLK
#error "unix_dirent_stubs.c: DT_BLK macro not found"
#endif
#ifndef DT_REG
#error "unix_dirent_stubs.c: DT_REG macro not found"
#endif
#ifndef DT_LNK
#error "unix_dirent_stubs.c: DT_LNK macro not found"
#endif
#ifndef DT_SOCK
#error "unix_dirent_stubs.c: DT_SOCK macro not found"
#endif
#ifndef DT_WHT
#error "unix_dirent_stubs.c: DT_WHT macro not found"
#endif

CAMLprim value unix_dirent_dt_unknown() { return Val_int(DT_UNKNOWN); }
CAMLprim value unix_dirent_dt_fifo() { return Val_int(DT_FIFO); }
CAMLprim value unix_dirent_dt_chr() { return Val_int(DT_CHR); }
CAMLprim value unix_dirent_dt_dir() { return Val_int(DT_DIR); }
CAMLprim value unix_dirent_dt_blk() { return Val_int(DT_BLK); }
CAMLprim value unix_dirent_dt_reg() { return Val_int(DT_REG); }
CAMLprim value unix_dirent_dt_lnk() { return Val_int(DT_LNK); }
CAMLprim value unix_dirent_dt_sock() { return Val_int(DT_SOCK); }
CAMLprim value unix_dirent_dt_wht() { return Val_int(DT_WHT); }
