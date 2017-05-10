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
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm$/],
      use: 'elm-webpack-loader?debug=true'
    },
    {
      test:    /\.html$/,
      exclude: /node_modules/,
      use:  'file-loader?name=[name].[ext]',
    },
    {
      test: /Stylesheets\.elm$/,
      use: ['style-loader', 'css-loader', 'elm-css-webpack-loader']
    },]
  },
  devServer: {
    inline: true,
    stats: { colors: true },
  },
}
