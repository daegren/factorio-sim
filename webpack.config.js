var path = require('path');

module.exports = {
  entry: {
    app: [
      'webpack-dev-server/client?http://127.0.0.1:8080/',
      './src/index.js'
    ]
  },
  output : {
    path: path.resolve(__dirname, 'build'),
    filename: 'bundle.js'
  },
  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack-loader'
    },
    {
      test:    /\.html$/,
      exclude: /node_modules/,
      loader:  'file-loader?name=[name].[ext]',
    },]
  },
  devServer: {
    inline: true,
    stats: { colors: true },
  },
}
