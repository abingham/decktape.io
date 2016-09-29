UNAME=$(shell uname)

ifeq ($(UNAME), Linux)
PHANTOM_OS=linux
endif
ifeq ($(UNAME), Darwin)
PHANTOM_OS=osx-cocoa
endif

elm:
	cd decktape_io/elm && \
	rm -Rf elm-stuff && \
	rm -f decktape_io.js && \
	elm-make Main.elm --yes --output=decktape_io.js

install_python:
	python setup.py install

install_decktape:
	rm -Rf decktape-1.0.0
	curl -L https://github.com/astefanutti/decktape/archive/v1.0.0.tar.gz | tar -xz --exclude phantomjs	
	curl -L https://github.com/astefanutti/decktape/releases/download/v1.0.0/phantomjs-$(PHANTOM_OS)-x86-64 -o decktape-1.0.0/phantomjs
	chmod +x decktape-1.0.0/phantomjs

install: elm install_python install_decktape
