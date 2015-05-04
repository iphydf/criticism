apps.native: $(wildcard *.ml) $(shell find apps -name "*.ml")
	ocamlbuild -use-ocamlfind -yaccflag --table $@

clean:
	ocamlbuild -clean
