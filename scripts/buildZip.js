// @flow strict
const { exec } = require('child_process');

const buildZip = async (dirName/*: string*/) => {
  const command = `cd ${dirName} && tar c -m -f ${dirName}.tar ./*`;
  return new Promise((resolve, reject) => {
    const zipProcess = exec(command, (error, stdout, stderr) => {
      if (!error) {
        resolve(`${dirName}/${dirName}.tar`);
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