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

#define _BSD_SOURCE

#include <stdint.h>
#include <dirent.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/threads.h>

#define IGN(x) (void)(x)
#define v value

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

CAMLprim v unix_dirent_dt_unknown(v _) { IGN(_); return Val_int(DT_UNKNOWN); }
CAMLprim v unix_dirent_dt_fifo(v _) { IGN(_); return Val_int(DT_FIFO); }
CAMLprim v unix_dirent_dt_chr(v _) { IGN(_); return Val_int(DT_CHR); }
CAMLprim v unix_dirent_dt_dir(v _) { IGN(_); return Val_int(DT_DIR); }
CAMLprim v unix_dirent_dt_blk(v _) { IGN(_); return Val_int(DT_BLK); }
CAMLprim v unix_dirent_dt_reg(v _) { IGN(_); return Val_int(DT_REG); }
CAMLprim v unix_dirent_dt_lnk(v _) { IGN(_); return Val_int(DT_LNK); }
CAMLprim v unix_dirent_dt_sock(v _) { IGN(_); return Val_int(DT_SOCK); }
CAMLprim v unix_dirent_dt_wht(v _) { IGN(_); return Val_int(DT_WHT); }

DIR *unix_dirent_opendir(const char *name) {
  DIR *retval;
  caml_release_runtime_system();
  retval = opendir(name);
  caml_acquire_runtime_system();
  return retval;
}

v unix_dirent_opendir_ptr (v _) {
  IGN(_); return caml_copy_int64((intptr_t)(void *)unix_dirent_opendir);
}

struct dirent *unix_dirent_readdir(DIR *dirp) {
  struct dirent *retval;
  caml_release_runtime_system();
  retval = readdir(dirp);
  caml_acquire_runtime_system();
  return retval;
}

v unix_dirent_readdir_ptr (v _) {
  IGN(_); return caml_copy_int64((intptr_t)(void *)unix_dirent_readdir);
}

int unix_dirent_closedir(DIR *dirp) {
  int retval;
  caml_release_runtime_system();
  retval = closedir(dirp);
  caml_acquire_runtime_system();
  return retval;
}

v unix_dirent_closedir_ptr (v _) {
  IGN(_); return caml_copy_int64((intptr_t)(void *)unix_dirent_closedir);
}
