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

module Ordered_dirent : Set.OrderedType with type t = Dirent.Dirent.t =
struct
  open Dirent.Dirent
  type t = Dirent.Dirent.t

  (* Ignore inodes; polymorphic compare is adequate for the other
     fields. *)
  let compare {kind=lkind; name=lname} {kind=rkind; name=rname} =
    Pervasives.compare (lkind, lname) (rkind, rname)
end

module Dirent_set = Set.Make(Ordered_dirent)

(* Retrieve all the dirents in a particular directory *) 
let read_all : string -> Dirent_set.t Lwt.t =
  fun dirname ->
  let open Lwt in
  Dirent_unix_lwt.opendir dirname >>= fun dir ->
  let rec loop items =
    Lwt.catch
      (fun () -> Dirent_unix_lwt.readdir dir >>= fun ent ->
                 return (`Value ent))
      (fun exn -> return (`Exception exn)) >>= function
      `Exception End_of_file -> return items
    | `Exception e -> Lwt.fail e
    | `Value item -> loop (Dirent_set.add item items)
  in loop Dirent_set.empty

module Readdir = struct
  let test_dir = "lwt_test/test-directory"

  let readdir_test () =
     let open Dirent in
     let open Dirent in
     let expected = Dirent_set.of_list [
       {ino=0L; kind=File_kind.DT_DIR; name="."};
       {ino=0L; kind=File_kind.DT_DIR; name=".."};
       {ino=0L; kind=File_kind.DT_LNK; name="symlink"};
       {ino=0L; kind=File_kind.DT_DIR; name="subdirectory"};
       {ino=0L; kind=File_kind.DT_REG; name="regular-file"};
     ] in
     assert
       (Dirent_set.equal 
          expected
          (Lwt_unix.run (read_all test_dir)))

  let tests = [
    "readdir",     `Quick, readdir_test;
  ]
end

let tests = [
  "readdir", Readdir.tests;
]

;;
Alcotest.run "Dirent_unix_lwt" tests
