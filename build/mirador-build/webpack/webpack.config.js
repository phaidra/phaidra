const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'mirador.min.js',
    path: path.resolve(__dirname, '../dist'),
    library: 'Mirador',
    libraryExport: 'default',
    libraryTarget: 'umd',
    publicPath: '/mirador/',
  },
  plugins: [
    new webpack.IgnorePlugin(/@blueprintjs\/(core|icons)/),
    new webpack.optimize.LimitChunkCountPlugin({ maxChunks: 1 }),
  ],
  resolve: {
    alias: {
      'react-draggable': path.resolve(
        __dirname,
        '../node_modules/react-draggable/build/cjs/cjs.js'
      ),
    },
    extensions: ['.js'],
  },
};
