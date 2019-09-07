// @flow strict
const { exec } = require('child_process');

const buildZip = async (dirName/*: string*/) => {
  const zipName = `${dirName}.zip`;
  const command = `find ${dirName} -exec touch -t 201401010000 {} + && cd ${dirName} && zip -X ../${zipName} ./*`;
  return new Promise((resolve, reject) => {
    const zipProcess = exec(command, (error, stdout, stderr) => {
      if (!error) {
        resolve(zipName);
      } else {
        reject(error);
      }
    });
  });
};

if (require.main === module) {
  const dirName = process.argv[2];
  buildZip(dirName);
}

module.exports = {
  buildZip,
};