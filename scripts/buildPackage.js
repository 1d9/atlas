// @flow strict
const { exec } = require('child_process');
const { EOL } = require('os');
const { mkdir, copyFile } = require('fs');
const { readStream } = require('./utils');
const { buildDockerrun } = require('./buildDockerrun');
const { buildCartographerConfig } = require('./buildCartographerConfig');
const { buildZip } = require('./buildZip');
const { buildHash } = require('./buildHash');

const buildPackage = async () => {
  try {
    const { tag, port, authentication } = JSON.parse(await readStream(process.stdin));
  
    await new Promise((resolve, reject) => mkdir('package', { recursive: true } , (err) => err ? reject(err) : resolve()));
  
    await buildDockerrun('package/Dockerrun.aws.json', tag, port, 'CONFIG_PATH');
    await buildCartographerConfig('package/prod.cartographer.json', port, { dir: 'local' }, authentication);
    const packageName = await buildZip('package');
    const packageHash = await buildHash(packageName);
    const hashedPackageName = await new Promise((resolve, reject) => {
      const filename = `${tag}-${packageHash.slice(0, 8)}.zip`;
      copyFile(packageName, filename, 0, (err) => err ? reject(err) : resolve(filename));
    });
    process.stdout.write(JSON.stringify({
      filename: hashedPackageName,
    }, null, 3) + EOL);
    process.exitCode = 0;
  } catch (error) {
    console.error(error);
    process.exitCode = 1;
  }
};

if (require.main === module) {
  buildPackage()
}

module.exports = {
  buildPackage,
};