var path = require('path');
var webpack = require('webpack');

const ExtractTextPlugin = require("extract-text-webpack-plugin")

var settings = {
  'dev': {
    devtool: 'eval-source-map',
    entry: {
      site: [
        'webpack-dev-server/client?http://webpack.shalendar.docker',
        'webpack/hot/dev-server',
        './src/site'
      ],
      calendar: [
        'webpack-dev-server/client?http://webpack.shalendar.docker',
        'webpack/hot/dev-server',
        './src/calendar'
      ]
    },
    output: {
      path: path.join(__dirname, 'static'),
      filename: '[name].js',
      publicPath: 'http://webpack.shalendar.docker/static/'
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loaders: ['babel'],
          include: path.join(__dirname, 'src')
        },{
          test: /\.scss$/,
          loaders: ["style", "css?sourceMap", "resolve-url", "sass?sourceMap"]
          //loaders: ["style", "css", "resolve-url", "sass?sourceMap"]
        },
        { test: /\.css$/, loader: "style!css" },
        { test: /\.png|gif|jpg|svg|woff2$/, loader: 'url-loader?limit=10240' },
        { test: /\.html$/, loader: 'html' },
        {
          test: /\.vue$/,
          loader: 'vue'
        }
      ]
    },
    devServer: { disableHostCheck: true },
    plugins: [
      new webpack.HotModuleReplacementPlugin(),
      new webpack.optimize.CommonsChunkPlugin("common", "common.js")
    ],
    resolve: {
      alias: {
        'vue$': 'vue/dist/vue.js'
      }
    }
  },

  'prod': {
    devtool: 'eval',
    entry: {
      site: './src/site',
      calendar: './src/calendar'
    },
    output: {
      path: '/app/public/static',
      filename: '[name].js',
      publicPath: '/static/'
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loaders: ['babel'],
          include: path.join(__dirname, 'src')
        },
        { test: /\.css|scss$/, loader: ExtractTextPlugin.extract("style", "css!resolve-url!sass?sourceMap") },
        { test: /\.css$/, loader: "style!css" },
        { test: /\.png|gif|jpg|svg|woff2$/, loader: 'url-loader?limit=10240' },
        { test: /\.html$/, loader: 'html' },
        {
          test: /\.vue$/,
          loader: 'vue'
        }
      ]
    },
    plugins: [
      new webpack.optimize.CommonsChunkPlugin("common", "common.js"),
      new ExtractTextPlugin("[name].css")
    ],
    resolve: {
      alias: {
        'vue$': 'vue/dist/vue.js'
      }
    }
  }
}

module.exports = settings[process.env.ENV]
