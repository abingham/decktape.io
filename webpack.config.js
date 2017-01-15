var path = require("path")
var BundleTracker = require('webpack-bundle-tracker')

var elmSource = __dirname + '/src'

module.exports = {
    context: __dirname,

    entry: {
        decktape_io: ['./src/index.js']
    },

    output: {
        path: path.resolve('./decktape_io/webpack/bundles/'),
        filename: "[name].js"
    },

    plugins: [
        new BundleTracker({filename: './decktape_io/webpack/stats.json'}),
    ],

    module: {
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            },
            {
                test:    /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader:  'elm-webpack?verbose=true&warn=true&cwd=' + elmSource,
            },
            {
                test:    /\.html$/,
                exclude: /node_modules/,
                loader:  'file?name=[name].[ext]',
            },
        ],
        noParse: /\.elm$/,
    },

    resolve: {
        modulesDirectories: ['node_modules'],
        extensions: ['', '.js']
    },
}
