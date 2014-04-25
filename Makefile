.PHONY: build install uninstall reinstall clean

FINDLIB_NAME=unix-dirent
MOD_NAME=unix_dirent
BUILD=_build/lib

BIND_UNIX := 1

ifeq ($(BIND_UNIX),0)
SRC=lib/no_unix
FLAGS=
EXTRA_META=requires = \"\"
CSRCS=
OBJS=
else
SRC=lib/unix
FLAGS=-package ctypes.foreign
EXTRA_META=requires = \"unix ctypes.foreign\"
CSRCS=$(SRC)/$(MOD_NAME)_stubs.c
OBJS=$(BUILD)/unix/$(MOD_NAME)_stubs.o
endif

CFLAGS=-fPIC -Wall -Wextra -Werror -std=c99

build: $(BUILD) $(OBJS)
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME)_private.cmi \
		-c lib/$(MOD_NAME)_private.ml
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME)_common.cmi \
		-c lib/$(MOD_NAME)_common.mli
	ocamlfind ocamlc -o $(BUILD)/$(MOD_NAME).cmi -I $(BUILD) -I lib \
		$(FLAGS) -c $(SRC)/$(MOD_NAME).mli
	ocamlfind ocamlmklib -o $(BUILD)/$(MOD_NAME) -I $(BUILD) \
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
