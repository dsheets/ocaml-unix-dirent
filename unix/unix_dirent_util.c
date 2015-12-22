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
#include <caml/alloc.h>
#include <caml/threads.h>

DIR *unix_dirent_opendir(const char *name) {
  DIR *retval;
  caml_release_runtime_system();
  retval = opendir(name);
  caml_acquire_runtime_system();
  return retval;
}

struct dirent *unix_dirent_readdir(DIR *dirp) {
  struct dirent *retval;
  caml_release_runtime_system();
  retval = readdir(dirp);
  caml_acquire_runtime_system();
  return retval;
}

int unix_dirent_closedir(DIR *dirp) {
  int retval;
  caml_release_runtime_system();
  retval = closedir(dirp);
  caml_acquire_runtime_system();
  return retval;
}
