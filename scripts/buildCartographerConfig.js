// @flow strict
const { readFile, writeFile } = require('fs');

const buildCartographerConfig = async (
  filename/*: string*/,
  port/*: number*/,
  storage/*: { dir: string } */,
  authentication/*: string */,
  origins/*: Array<string> */,
) => {
  const cartographerConfig = {
    port,
    storage: {
      type: 'local-json',
      dir: storage.dir,
    },
    cors: { origins },
    authentication: {
      type: 'fixed',
      name: authentication,
      pass: '1234',
      userId: '0',
    },
  };

  const cartographerConfigString = JSON.stringify(cartographerConfig, null, 3);
  return new Promise((resolve, reject) => {
    writeFile(filename, cartographerConfigString, 'utf8', (err) => {
      if (err) {
        reject(err);
      } else {
        resolve(cartographerConfig);
      }
    });
  });
};

if (require.main === module) {
  const filename = process.argv[2];
  const port = parseInt(process.argv[3], 10);
  const storage = { dir: process.argv[4], };
  const authentication = process.argv[5];
  buildCartographerConfig(filename, port, storage, authentication, []);
}

module.exports = {
  buildCartographerConfig,
};
