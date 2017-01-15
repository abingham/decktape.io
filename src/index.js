'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');

setTimeout(function() {
    var mountNode = document.getElementById('decktape-io');

    // .embed() can take an optional second argument. This would be an object
    // describing the data we need to start a program, i.e. a userID or some
    // token
    var app = Elm.DecktapeIO.embed(mountNode);
}, 10);
