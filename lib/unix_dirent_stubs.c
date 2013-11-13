#include <dirent.h>
#include <caml/mlvalues.h>

#ifndef DT_UNKNOWN
#define DT_UNKNOWN (-1)
#endif
#ifndef DT_FIFO
#define DT_FIFO (-1)
#endif
#ifndef DT_CHR
#define DT_CHR (-1)
#endif
#ifndef DT_DIR
#define DT_DIR (-1)
#endif
#ifndef DT_BLK
#define DT_BLK (-1)
#endif
#ifndef DT_REG
#define DT_REG (-1)
#endif
#ifndef DT_LNK
#define DT_LNK (-1)
#endif
#ifndef DT_SOCK
#define DT_SOCK (-1)
#endif
#ifndef DT_WHT
#define DT_WHT (-1)
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
