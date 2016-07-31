decktape_io README
==================

This assumes that decktape itself (and phantomjs) is installed in a directory
called "decktape" which is a sibling to this file. For example:

```
git clone --depth 1 https://github.com/astefanutti/decktape.git
cd decktape
# on OSX
curl -L http://astefanutti.github.io/decktape/downloads/phantomjs-osx-cocoa-x86-64 -o bin/phantomjs
chmod +x bin/phantomjs
```

See [the decktape project](https://github.com/astefanutti/decktape/) for more
info.

Getting Started
---------------

- cd <directory containing this file>

- $VENV/bin/pip install -e .

- $VENV/bin/pserve development.ini
