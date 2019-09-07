// @flow strict
const crypto = require('crypto');
const { createReadStream } = require('fs');

const hashAlgo = 'sha1';

const buildHash = async (filename/*: string*/) => {
  const stream = createReadStream(filename, 'utf8');
  const hash = crypto.createHash(hashAlgo);
  
  hash.setEncoding('hex');
  const hashPromise = new Promise((resolve, reject) => {
    stream.on('end', () => {
      hash.end();
      const result = hash.read();
      if (!result) {
        reject(new Error('No Hash'));
      } else {
        resolve(result.toString());
      }
    });
  });
  
  stream.pipe(hash);
  return hashPromise;
};

if (require.main === module) {
  const filename = process.argv[2];
  buildHash(filename);
}

module.exports = {
  buildHash,
};