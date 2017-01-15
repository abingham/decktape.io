[![Build Status](https://travis-ci.org/abingham/decktape.io.png?branch=master)](https://travis-ci.org/abingham/decktape.io) [![Code Health](https://landscape.io/github/abingham/decktape.io/master/landscape.svg?style=flat)](https://landscape.io/github/abingham/decktape.io/master)

# decktape_io README

## Installing decktape

DeckTape.io assumes that decktape itself (and phantomjs) is installed in a directory
called "decktape-1.0.0" which is a sibling to this file. For example:

```
curl -L https://github.com/astefanutti/decktape/archive/v1.0.0.tar.gz | tar -xz --exclude phantomjs
cd decktape-1.0.0
# on OSX
curl -L https://github.com/astefanutti/decktape/releases/download/v1.0.0/phantomjs-osx-cocoa-x86-64 -o phantomjs
chmod +x phantomjs
```

See [the decktape project](https://github.com/astefaservernutti/decktape/) for more
info.

## Installing decktape.io

1. Install the [npm](https://www.npmjs.com/) dependencies
([installing npm](https://docs.npmjs.com/getting-started/installing-node) first
if necessary):

```
npm install
```

2. Compile the elm portions of the site

```
npm run build
```

Note that this isn't strictly necessary if you're going to use webpack's file
watching capabilities during development.

3. Install the Python components. It's probably best to do this in a virtual environment.

```
python setup.py install
```

## Running decktape.io

decktape.io has two main moving parts:

 1. The pyramid web server managing the web bits
 2. A celery worker managing the conversion jobs

decktape.io also needs two services running:

 1. rabbit-mq: for celery
 2. mongodb: for storing conversion results

### Running decktape.io during development

The simplest way to run decktape during development is to use node-foreman to
manage the web server, run the celery worker, and to recompile the Elm code when
it changes. First, install node-foreman:
```
npm install -g node-foreman
```

Then from the top-level directory you can run the `nf` command to manage the
executable elements:
```
nf start
```

### Running the parts individually

Assuming that rabbitmq and mongodb are running, you first need to start at least
one worker:

``` celery -A decktape_io.worker worker ```

This will occupy a terminal, so just let it be.

Next you need to start the webserver. This could be using WSGI behind a proxy or whatever - the options are limitless - but the simplest form is like this:
```
pserve development.ini
```

This will start a Pyramid server on port 6543.

At this point you should have a fully functions system!

## Running tests

If you want to run the tests, you need to install a few more Python
dependencies:
```
pip install --upgrade -r dev_requirements.txt
```

Then run the tests using pytest:
```
pytest test
```
