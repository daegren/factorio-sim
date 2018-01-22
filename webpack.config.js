var path = require("path");

module.exports = {
  entry: {
    app: ["webpack-dev-server/client?http://127.0.0.1:8080/", "./src/index.js"]
  },
  output: {
    path: path.resolve(__dirname, "build"),
    filename: "bundle.js",
    publicPath: "/build/"
  },
  resolve: {
    alias: {
      assets: path.resolve(__dirname, "assets")
    }
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: "elm-webpack-loader?debug=true"
      },
      {
        test: /\.(html|png)$/,
        exclude: /node_modules/,
        use: "file-loader?name=[name].[ext]"
      }
    ]
  },
  devServer: {
    inline: true,
    stats: { colors: true }
  }
};
