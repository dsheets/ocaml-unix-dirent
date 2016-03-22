/*
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
 */

#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include <dirent.h>

#include "caml/memory.h"
#include "caml/alloc.h"

#include "lwt_unix.h"

struct job_readdir {
  struct lwt_unix_job job;
  DIR *dir;
  struct dirent *entry, *result;
  int error_code;
  const char *failed_function;
};

static long readdir_buffer_size(DIR *dir, const char **failure)
{
  int fd = dirfd(dir);
  if (fd == -1) {
    *failure = "dirfd";
    return -1;
  }
  
  long max_name = fpathconf(fd, _PC_NAME_MAX);
  if (max_name == -1) {
    *failure = "fpathconf";
    return -1;
  }

  return max_name + offsetof(struct dirent, d_name) + 1;
}

static void worker_readdir(struct job_readdir *job)
{
  long bufsize = readdir_buffer_size(job->dir, &job->failed_function);
  if (bufsize != -1) {
    job->entry = caml_stat_alloc(bufsize);
    job->error_code = readdir_r(job->dir, job->entry, &job->result);
  }
  else {
    job->error_code = errno;
  }
}

static value result_readdir(struct job_readdir *job)
{
  CAMLparam0 ();

  if (job->failed_function != NULL) {
    /* Error of int * string */
    CAMLlocal1 (error);
    error = caml_alloc(2, 0);
    Store_field(error, 0, Val_int(job->error_code));
    Store_field(error, 1, caml_copy_string(job->failed_function));

    lwt_unix_free_job(&job->job);
    CAMLreturn (error);
  }
  else if (job->error_code != 0) {
    /* Error of int * string */
    CAMLlocal1 (error);
    error = caml_alloc(2, 0);
    Store_field(error, 0, Val_int(job->error_code));
    Store_field(error, 1, caml_copy_string("readdir"));

    caml_stat_free(job->entry);
    lwt_unix_free_job(&job->job);

    CAMLreturn (error);
  }
  else if (job->result != NULL) {
    /* Next of int64 * char * string */
    CAMLlocal1 (next);
    next = caml_alloc(3, 1);
    Store_field (next, 0, caml_copy_int64(job->entry->d_ino));
    Store_field (next, 1, Val_int(job->entry->d_type));
    Store_field (next, 2, caml_copy_string(job->entry->d_name));

    caml_stat_free(job->entry);
    lwt_unix_free_job(&job->job);
    CAMLreturn (next);
  }
  else {
    /* End_of_stream */
    caml_stat_free(job->entry);
    lwt_unix_free_job(&job->job);
    CAMLreturn (Val_int(1));
  }
}

CAMLprim
value unix_dirent_lwt_readdir_job(value handle)
{
  CAMLparam1(handle);
  LWT_UNIX_INIT_JOB(job, readdir, 0);
  job->dir = (DIR *)Nativeint_val(handle);
  job->entry = job->result = NULL;
  job->error_code = 0;
  job->failed_function = NULL;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}
