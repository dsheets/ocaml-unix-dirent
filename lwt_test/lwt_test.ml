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
let read_all : string -> Dirent_set.t Lwt.t = fun dirname ->
  let open Lwt in
  Dirent_unix_lwt.opendir dirname >>= fun dir ->
  let rec loop items =
    Lwt.catch
      (fun () ->
         Lwt.catch (fun () ->
           Lwt_unix.openfile "does_not_exist" [] 0
           >>= fun _ ->
           Lwt.return_unit
         ) (fun _ -> Lwt.return_unit)
         >>= fun () ->
         Dirent_unix_lwt.readdir dir >>= fun ent ->
         return (`Value ent))
      (fun exn -> return (`Exception exn)) >>= function
      `Exception End_of_file -> return items
    | `Exception e -> Lwt.fail e
    | `Value item -> loop (Dirent_set.add item items)
  in
  loop Dirent_set.empty
  >>= fun set ->
  Dirent_unix_lwt.closedir dir
  >>= fun () ->
  Lwt.return set

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
     Alcotest.check dirent_set "readdir sets"
       expected
       (Lwt_unix.run (read_all test_dir))

  let tests = [
    "readdir",     `Quick, readdir_test;
  ]
end

let tests = [
  "readdir", Readdir.tests;
]

;;
Alcotest.run "Dirent_unix_lwt" tests
