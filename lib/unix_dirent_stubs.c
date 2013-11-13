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
