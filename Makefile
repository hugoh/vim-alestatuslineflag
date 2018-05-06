.PHONY: default lint test testsetup doc

PLUGIN=alestatusline

default: lint testsetup test doc

lint:
	vint autoload/${PLUGIN}.vim

testsetup:
	test/setup.sh

test: testsetup
	test/run.sh

doc: doc/${PLUGIN}.txt

doc/${PLUGIN}.txt: autoload/${PLUGIN}.vim addon-info.json
	vimdoc .
