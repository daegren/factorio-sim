var path = require('path');

module.exports = {
  entry: {
    bundle: [
      './src/index.js'
    ]
  },
  output : {
    path: path.resolve(__dirname, 'build'),
    filename: '[name].js',
    publicPath: '/factorio-sim/build/',
  },
  resolve: {
    alias: {
      'assets': path.resolve(__dirname, 'assets')
    }
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm$/],
      use: 'elm-webpack-loader'
    },
    {
      test:    /\.(html|png)$/,
      exclude: /node_modules/,
      use:  'file-loader?name=[name].[ext]',
    },
    {
      test: /Stylesheets\.elm$/,
      use: ['style-loader', 'css-loader', 'elm-css-webpack-loader']
    },]
  },
  devtool: 'source-map',
}
