import zlib from 'zlib'
import { Buffer } from 'buffer'

export function parse(string, callback) {
  const str = string.substring(1, string.length)
  const buff = Buffer.from(str, 'base64')
  zlib.unzip(buff, (err, buf) => {
    if (!err) {
      console.log('inflated', buf.toString());
      callback(JSON.parse(buf.toString()))
    } else {
      console.error(err);
    }
  })
}
