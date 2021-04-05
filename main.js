const copydir = require("copy-dir");
const sri = require("@pobedit/sri");
const replaceinfile = require("replace-in-file");

const index = "./build/web/index.html";
const adsense = "./build/web/adsense.html";

async function runSri() {
  var headjs = await sri.generate("./build/web/head.js");
  console.log(headjs);
  headjs = replaceinfile.sync({
    files: index,
    from: '<script src="./head.js" type="application/javascript"></script>',
    to:
      '<script src="./head.js" type="application/javascript" integrity="' +
      headjs +
      '"></script>',
    countMatches: true,
  });
  console.log(headjs);

  var darkjs = await sri.generate("./build/web/dark.js");
  console.log(darkjs);
  darkjs = replaceinfile.sync({
    files: index,
    from: '<script src="./dark.js" type="application/javascript"></script>',
    to:
      '<script src="./dark.js" type="application/javascript" integrity="' +
      darkjs +
      '"></script>',
    countMatches: true,
  });
  console.log(darkjs);

  var firebasejs = await sri.generate("./build/web/firebase.js");
  console.log(firebasejs);
  firebasejs = replaceinfile.sync({
    files: index,
    from: '<script src="./firebase.js" type="application/javascript"></script>',
    to:
      '<script src="./firebase.js" type="application/javascript" integrity="' +
      firebasejs +
      '"></script>',
    countMatches: true,
  });
  console.log(firebasejs);

  var flybisjs = await sri.generate("./build/web/flybis.js");
  console.log(flybisjs);
  flybisjs = replaceinfile.sync({
    files: index,
    from: '<script src="./flybis.js" type="application/javascript"></script>',
    to:
      '<script src="./flybis.js" type="application/javascript" integrity="' +
      flybisjs +
      '"></script>',
    countMatches: true,
  });
  console.log(flybisjs);

  var maindartjs = await sri.generate("./build/web/main.dart.js");
  console.log(maindartjs);
  maindartjs = replaceinfile.sync({
    files: index,
    from:
      '<script src="./main.dart.js" type="application/javascript"></script>',
    to:
      '<script src="./main.dart.js" type="application/javascript" integrity="' +
      maindartjs +
      '"></script>',
    countMatches: true,
  });
  console.log(maindartjs);

  var workerjs = await sri.generate("./build/web/worker.js");
  console.log(workerjs);
  workerjs = replaceinfile.sync({
    files: index,
    from: '<script src="./worker.js" type="application/javascript"></script>',
    to:
      '<script src="./worker.js" type="application/javascript" integrity="' +
      workerjs +
      '"></script>',
    countMatches: true,
  });
  console.log(workerjs);

  var adsensejs = await sri.generate("./build/web/adsense.js");
  console.log(adsensejs);
  adsensejs = replaceinfile.sync({
    files: adsense,
    from: '<script src="./adsense.js" type="application/javascript"></script>',
    to:
      '<script src="./adsense.js" type="application/javascript" integrity="' +
      adsensejs +
      '"></script>',
    countMatches: true,
  });
  console.log(adsensejs);
}

function runCopydir() {
  // Flutter
  copydir.sync("./build/web", "./public/app", {
    utimes: true, // keep add time and modify time
    mode: true, // keep file mode
    cover: true, // cover file when exists, default is true
  });
  copydir.sync("./build/web/public", "./public", {
    utimes: true, // keep add time and modify time
    mode: true, // keep file mode
    cover: true, // cover file when exists, default is true
  });

  // React
  copydir.sync("./react/build", "./public", {
    utimes: true, // keep add time and modify time
    mode: true, // keep file mode
    cover: true, // cover file when exists, default is true
  });

  // Electron
  copydir.sync("./build/web", "./electron/app", {
    utimes: true, // keep add time and modify time
    mode: true, // keep file mode
    cover: true, // cover file when exists, default is true
  });
  copydir.sync("./build/web/public", "./electron/app", {
    utimes: true, // keep add time and modify time
    mode: true, // keep file mode
    cover: true, // cover file when exists, default is true
  });
}

async function start() {
  await runSri();
  runCopydir();
}

start();
