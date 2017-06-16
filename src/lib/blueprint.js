import zlib from 'zlib'
import { Buffer } from 'buffer'

export function parse(string, callback) {
  const str = string.substring(1, string.length)
  const buff = Buffer.from(str, 'base64')
  zlib.inflate(buff, (err, buf) => {
    if (!err) {
      callback(JSON.parse(buf.toString()))
    } else {
      console.error(err);
    }
  })
}

export function exportBlueprint(blueprint, callback) {
  const buff = Buffer.from(JSON.stringify(blueprint), 'utf8')
  zlib.deflate(buff, (err, buf) => {
    if (!err) {
      const result = `0${buf.toString('base64')}`
      callback(result)
    }
  })
}
