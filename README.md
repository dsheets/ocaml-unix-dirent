ocaml-unix-dirent
=================

[ocaml-unix-dirent](https://github.com/dsheets/ocaml-unix-dirent) provides
access to the features exposed in [`dirent.h`][dirent.h] in a way that is not
tied to the implementation on the host system.

The [`Dirent`][dirent] module provides functions for translating
between the file kinds accessible through `dirent.h` and their values
on particular systems.

The [`Dirent_unix`][dirent_unix] provides bindings to functions that use the
types in `Dirent` along with a representation of the host system.  The
bindings support a more comprehensive range of file kinds than the corresponding
functions in the standard OCaml `Unix` module.  The
[`Dirent_unix_lwt`][dirent_unix_lwt] module exports non-blocking versions of
the functions in `Dirent_unix` based on the [Lwt][lwt] cooperative threading
library.

[dirent.h]: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/dirent.h.html
[dirent]: https://github.com/dsheets/ocaml-unix-dirent/blob/master/lib/dirent.mli
[dirent_host]: https://github.com/dsheets/ocaml-unix-dirent/blob/master/lib/dirent_host.mli
[dirent_unix]: https://github.com/dsheets/ocaml-unix-dirent/blob/master/unix/dirent_unix.mli
[dirent_unix_lwt]: https://github.com/dsheets/ocaml-unix-dirent/blob/master/lwt/dirent_unix_lwt.mli
[lwt]: http://ocsigen.org/lwt/
