[![Build Status](https://travis-ci.org/abingham/decktape.io.png?branch=master)](https://travis-ci.org/abingham/decktape.io) [![Code Health](https://landscape.io/github/abingham/decktape.io/master/landscape.svg?style=flat)](https://landscape.io/github/abingham/decktape.io/master)

decktape_io README
==================

This assumes that decktape itself (and phantomjs) is installed in a directory
called "decktape-1.0.0" which is a sibling to this file. For example:

```
curl -L https://github.com/astefanutti/decktape/archive/v1.0.0.tar.gz | tar -xz --exclude phantomjs
cd decktape-1.0.0
# on OSX
curl -L https://github.com/astefanutti/decktape/releases/download/v1.0.0/phantomjs-osx-cocoa-x86-64 -o phantomjs
chmod +x phantomjs
```

See [the decktape project](https://github.com/astefanutti/decktape/) for more
info.

Getting Started
---------------

```
cd <directory containing this file>
$VENV/bin/pip install -e .
pushd decktape_io/elm
elm-make Main.elm --yes --output=decktape_io.js
popd
$VENV/bin/pserve development.ini
```
