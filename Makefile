apps.native: $(wildcard *.ml) $(shell find apps -name "*.ml")
	ocamlbuild -use-ocamlfind $@
