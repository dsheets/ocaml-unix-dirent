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

let opendir path = Lwt.catch
    (fun () -> Lwt_unix.opendir path)
    (fun exn -> Lwt.fail (Errno_unix.to_errno_exn exn))

let closedir dh = Lwt.catch
    (fun () -> Lwt_unix.closedir dh)
    (fun exn -> Lwt.fail (Errno_unix.to_errno_exn exn))

type readdir_result =
  | Error of int * string
  | Next of int64 * char * string
  | End_of_stream

external make_readdir_job : nativeint -> readdir_result Lwt_unix.job =
   "unix_dirent_lwt_readdir_job"

let readdir handle =
  let open Lwt in
  let nhandle = Unix_representations.nativeint_of_dir_handle handle in
  Lwt_unix.run_job (make_readdir_job nhandle) >>= function
  | End_of_stream -> Lwt.fail End_of_file
  | Error (errno, call) ->
    Errno_unix.raise_errno ~call ~label:(Nativeint.to_string nhandle) errno
  | Next (ino, kind, name) ->
    let localhost = Dirent_unix.File_kind.host in
    let file_kind = match Dirent.File_kind.of_code localhost kind with
      | Some file_kind -> file_kind
      | None -> Dirent.File_kind.DT_UNKNOWN
    in
    Lwt.return (Dirent.Dirent.{ ino; kind = file_kind; name })
