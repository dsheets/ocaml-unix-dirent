.PHONY: build install uninstall reinstall clean

FINDLIB_NAME=unix-dirent
MOD_NAME=unix_dirent
BUILD=_build/lib

BIND_UNIX := 1

ifeq ($(BIND_UNIX),0)
SRC=lib/no_unix
FLAGS=-package ctypes -package sexplib.syntax -package comparelib.syntax -package bin_prot.syntax
EXTRA_META=requires = \"ctypes sexplib.syntax comparelib.syntax bin_prot.syntax\"
CSRCS=
OBJS=
else
SRC=lib/unix
FLAGS=-package ctypes.foreign -package sexplib.syntax -package comparelib.syntax -package bin_prot.syntax
EXTRA_META=requires = \"unix ctypes.foreign sexplib.syntax comparelib.syntax bin_prot.syntax\"
CSRCS=$(SRC)/$(MOD_NAME)_stubs.c
OBJS=$(BUILD)/unix/$(MOD_NAME)_stubs.o
endif

CFLAGS=-fPIC -Wall -Wextra -Werror -std=c99

build: $(BUILD) $(OBJS)
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME)_private.cmi \
		-syntax camlp4o $(FLAGS) -c lib/$(MOD_NAME)_private.ml
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME)_common.cmi \
		-syntax camlp4o $(FLAGS) -c lib/$(MOD_NAME)_common.mli
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME).cmi -I $(BUILD) -I lib \
		-syntax camlp4o $(FLAGS) -c $(SRC)/$(MOD_NAME).mli
	ocamlfind ocamlmklib -o $(BUILD)/$(MOD_NAME) -I $(BUILD) \
		-ocamlc   "ocamlfind ocamlc -syntax camlp4o $(FLAGS)" \
		-ocamlopt "ocamlfind ocamlopt -syntax camlp4o $(FLAGS)" \
		$(FLAGS) lib/$(MOD_NAME)_private.ml lib/$(MOD_NAME)_common.ml \
		$(SRC)/$(MOD_NAME).ml $(OBJS)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/unix/$(MOD_NAME)_stubs.o: $(SRC)/$(MOD_NAME)_stubs.c $(BUILD)
	mkdir -p $(BUILD)/unix
	cc -c $(CFLAGS) -o $@ $< -I$(shell ocamlc -where)

META: META.in
	cp META.in META
	echo $(EXTRA_META) >> META

install: META
	ocamlfind install $(FINDLIB_NAME) META \
		$(SRC)/$(MOD_NAME).mli \
		$(BUILD)/$(MOD_NAME).cmi \
		$(BUILD)/$(MOD_NAME).cma \
		$(BUILD)/$(MOD_NAME).cmxa \
		-dll $(BUILD)/dll$(MOD_NAME).so \
		-nodll $(BUILD)/lib$(MOD_NAME).a $(BUILD)/$(MOD_NAME).a

uninstall:
	ocamlfind remove $(FINDLIB_NAME)

reinstall: uninstall install

clean:
	rm -rf _build
	bash -c "rm -f lib/$(MOD_NAME)_{common,private}.{cm?,o} META"
	bash -c "rm -f lib/{unix,no_unix}/$(MOD_NAME).{cm?,o}"
