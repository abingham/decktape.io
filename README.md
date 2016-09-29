[![Build Status](https://travis-ci.org/abingham/decktape.io.png?branch=master)](https://travis-ci.org/abingham/decktape.io) [![Code Health](https://landscape.io/github/abingham/decktape.io/master/landscape.svg?style=flat)](https://landscape.io/github/abingham/decktape.io/master)

decktape_io README
==================

Installing decktape
-------------------

DeckTape.io assumes that decktape itself (and phantomjs) is installed in a directory
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

Installing decktape.io
----------------------

First make sure you've installed [elm](elm-lang.org). This is needed to compile the elm-based parts of the app.

1. Compile the elm portions of the site
```
pushd decktape_io/elm
elm-make Main.elm --yes --output=decktape_io.js
popd
```

2. Install the Python components. It's probably best to do this in a virtual environment.

```
python setup.py install
```

Running decktape.io
-------------------

decktape.io requires mongodb and rabbitmq be running. Assuming they're up, you
first need to start at least one worker:
```
celery -A decktape_io.worker worker
```

This will occupy a terminal, so just let it be.

Next you need to start the webserver. This could be using WSGI behind a proxy or whatever - the options are limitless - but the simplest form is like this:
```
pserve development.ini
```

This will start a Pyramid server on port 6543.

At this point you should have a fully functions system!

Running tests
-------------

If you want to run the tests, you need to install a few more Python
dependencies:
```
pip install --upgrade -r dev_requirements.txt
```

Then run the tests using pytest:
```
pytest test
```
