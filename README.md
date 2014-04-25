ocaml-unix-dirent
================

[ocaml-unix-dirent](https://github.com/dsheets/ocaml-unix-dirent) provides
host-dependent dirent.h access.

**WARNING**: not portable due to *opendir*, *readdir*, and *closedir*
wrappers that assume 64-bit instruction pointers.
Also, the *dirent* struct layout is specific to Linux x86-64. This is
not ideal.
