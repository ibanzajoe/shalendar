var path = require('path');
var webpack = require('webpack');

const ExtractTextPlugin = require("extract-text-webpack-plugin")

const url = `http://${process.env.VIRTUAL_HOST}`
console.log(url)
var settings = {
  'dev': {
    devtool: 'source-map',
    entry: [
      `webpack-dev-server/client?${url}`,
      'webpack/hot/dev-server',
      './src/index'
    ],
    output: {
      path: path.join(__dirname, 'static'),
      filename: 'bundle.js',
      publicPath: url + '/static/'
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loaders: ['babel'],
          include: path.join(__dirname, 'src')
        },{
          test: /\.scss$/,
          loaders: ["style", "css?sourceMap", "sass?sourceMap"]
        },
        { test: /\.css$/, loader: "style!css" },
        { test: /\.png$/, loader: 'url-loader?limit=10240' },
        { test: /\.html$/, loader: 'html' }
      ]
    },
    plugins: [
      new webpack.HotModuleReplacementPlugin()
    ]
  },

  'prod': {
    devtool: 'eval',
    entry: [
      './src/index'
    ],
    output: {
      path: '/app/public/static',
      filename: 'bundle.js',
      publicPath: 'http://webpack.shalendar.docker/static/'
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loaders: ['babel'],
          include: path.join(__dirname, 'src')
        },
        { test: /\.css|scss$/, loader: ExtractTextPlugin.extract("style", "css!sass") },
        { test: /\.css$/, loader: "style!css" },
        { test: /\.png$/, loader: 'url-loader?limit=10240' },
        { test: /\.html$/, loader: 'html' }
      ]
    },
    plugins: [
      new ExtractTextPlugin("styles.css")
    ]
  }
}


console.log("WTF", settings[process.env.ENV])

module.exports = settings[process.env.ENV]
