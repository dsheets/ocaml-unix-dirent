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

module Ordered_dirent : Set.OrderedType with type t = Dirent.Dirent.t =
struct
  open Dirent.Dirent
  type t = Dirent.Dirent.t

  (* Ignore inodes; polymorphic compare is adequate for the other
     fields. *)
  let compare {kind=lkind; name=lname} {kind=rkind; name=rname} =
    Pervasives.compare (lkind, lname) (rkind, rname)
end

module Dirent_set = struct
  include Set.Make(Ordered_dirent)

  let pp_dirent fmt dirent =
    let open Dirent.Dirent in
    (* inodes elided as above *)
    Format.fprintf fmt "{kind=%s; name=%s}"
      (Dirent.File_kind.to_string dirent.kind)
      dirent.name

  let pp fmt set =
    Format.pp_print_newline fmt ();
    Format.pp_print_list pp_dirent fmt (elements set)
end

let dirent_set =
  (module Dirent_set : Alcotest.TESTABLE with type t = Dirent_set.t)

(* Retrieve all the dirents in a particular directory *)
let read_all : string -> Dirent_set.t = fun dirname ->
  let dir = Unix.opendir dirname in
  let rec loop items =
    match (try `Value (Dirent_unix.readdir dir)
           with End_of_file -> `Exception End_of_file
          )
    with
    | `Exception End_of_file -> items
    | `Exception e -> raise e
    | `Value item -> loop (Dirent_set.add item items)
  in
  let set = loop Dirent_set.empty in
  Dirent_unix.closedir dir;
  set

module Readdir = struct
  let test_dir = "unix_test/test-directory"

  let readdir () =
    let open Dirent in
    let open Dirent in
    let expected = Dirent_set.of_list [
      {ino=0L; kind=File_kind.DT_DIR; name="."};
      {ino=0L; kind=File_kind.DT_DIR; name=".."};
      {ino=0L; kind=File_kind.DT_LNK; name="symlink"};
      {ino=0L; kind=File_kind.DT_DIR; name="subdirectory"};
      {ino=0L; kind=File_kind.DT_REG; name="regular-file"};
    ] in
    Alcotest.check dirent_set "readdir sets"
      expected
      (read_all test_dir)

  let tests = [
    "readdir",                `Quick, readdir;
  ]
end

let tests = [
  "readdir", Readdir.tests;
]

;;
Alcotest.run "Dirent_unix" tests
