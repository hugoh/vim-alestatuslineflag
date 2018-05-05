.PHONY: default lint doc

PLUGIN=alestatuslineflag

default: lint doc

lint:
	vint plugin/${PLUGIN}.vim

doc: doc/${PLUGIN}.txt

doc/${PLUGIN}.txt: plugin/${PLUGIN}.vim addon-info.json
	vimdoc .
