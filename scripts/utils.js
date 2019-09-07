// @flow strict
/*::
import type { Readable } from 'stream';
*/

const readStream = async (stream/*: Readable*/) => new Promise((resolve, reject) => {
  const chunks = [];
  stream.on('data', chunk => chunks.push(chunk));
  stream.on('error', error => reject(error));
  stream.on('end', () => resolve(chunks.join('')));
});

module.exports = {
  readStream,
};