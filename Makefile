.PHONY: build test install uninstall reinstall clean

FINDLIB_NAME=unix-dirent
MOD_NAME=unix_dirent

OCAML_LIB_DIR=$(shell ocamlc -where)

CTYPES_LIB_DIR=$(shell ocamlfind query ctypes)

OCAMLBUILD=CTYPES_LIB_DIR=$(CTYPES_LIB_DIR) OCAML_LIB_DIR=$(OCAML_LIB_DIR) \
	ocamlbuild -use-ocamlfind -classic-display

WITH_UNIX=$(shell ocamlfind query ctypes unix > /dev/null 2>&1 ; echo $$?)

TARGETS=.cma .cmxa

PRODUCTS=$(addprefix dirent,$(TARGETS))

ifeq ($(WITH_UNIX), 0)
PRODUCTS+=$(addprefix $(MOD_NAME),$(TARGETS)) \
          lib$(MOD_NAME)_stubs.a dll$(MOD_NAME)_stubs.so
endif

TYPES=.mli .cmi .cmti

INSTALL:=$(addprefix dirent,$(TYPES)) \
         $(addprefix dirent,$(TARGETS))

INSTALL:=$(addprefix _build/lib/,$(INSTALL))

ifeq ($(WITH_UNIX), 0)
INSTALL_UNIX:=$(addprefix dirent_unix,$(TYPES)) \
              $(addprefix $(MOD_NAME),$(TARGETS))

INSTALL_UNIX:=$(addprefix _build/unix/,$(INSTALL_UNIX))

INSTALL+=$(INSTALL_UNIX)
endif

ARCHIVES:=_build/lib/dirent.a

ifeq ($(WITH_UNIX), 0)
ARCHIVES+=_build/unix/$(MOD_NAME).a
endif

build:
	$(OCAMLBUILD) $(PRODUCTS)

test: build
	$(OCAMLBUILD) unix_test/test.native
	./test.native

install:
	ocamlfind install $(FINDLIB_NAME) META \
		$(INSTALL) \
		-dll _build/unix/dll$(MOD_NAME)_stubs.so \
		-nodll _build/unix/lib$(MOD_NAME)_stubs.a \
		$(ARCHIVES)

uninstall:
	ocamlfind remove $(FINDLIB_NAME)

reinstall: uninstall install

clean:
	ocamlbuild -clean
	rm -f lib/dirent.cm? unix/dirent_unix.cm? \
	      lib/dirent.o unix/dirent_unix.o
