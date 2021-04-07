#!/usr/bin/env node

const program = require("commander");
const package = require("./package.json");

const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");

program.version(package.version);

program
  .command("web-build")
  .description("Compilar builds Web.")
  .action(() => {
    exec("flutter build web --release", (error, stdout, stderr) => {
      console.log("📦 FLUTTER BUILD");
      console.log(stdout);

      exec("cd react && npm run build", (error, stdout, stderr) => {
        console.log("📦 REACT BUILD");
        console.log(stdout);

        exec("flybis web-minify", (error, stdout, stderr) => {
          console.log("📦 WEB MINIFY");
          console.log(stdout);

          exec("flybis web-copy", (error, stdout, stderr) => {
            console.log("📦 WEB COPY");
            console.log(stdout);
          });
        });
      });
    });
  });

program
  .command("web-minify")
  .description("Minimizar scripts da build Web.")
  .action(() => {
    const terser = require("terser");

    const files = [
      "/build/web/adsense.js",
      "/build/web/dark.js",
      "/build/web/electron-firebase-messaging-sw.js",
      "/build/web/public/firebase-messaging-sw.js",
      "/build/web/firebase.js",
      "/build/web/flybis.js",
      "/build/web/head.js",
      "/build/web/load.js",
      "/build/web/worker.js",
      "/build/web/main.dart.js",
      "/build/web/flutter_service_worker.js",
    ];

    files.forEach(async (file) => {
      let location = path.join(__dirname, file);

      let original = await fs.promises.readFile(location, "utf-8");

      console.log({ original });

      let minify = await terser.minify(original, {
        sourceMap: true,
        mangle: true,
        compress: true,
        toplevel: true,
        ie8: true,
      }).code;

      console.log({ minify });

      await fs.promises.writeFile(location, minify);

      console.log({ location });
    });
  });

program
  .command("web-copy")
  .description("Copiar build Web para os diretórios corretos.")
  .action(() => {
    const fsExtra = require("fs-extra");
    const copyDir = require("copy-dir");

    const paths = [
      {
        input: "/build/web",
        output: "/public/app",
      },
      {
        input: "/build/web/public",
        output: "/public",
      },
      {
        input: "/react/build",
        output: "/public",
      },
      {
        input: "/build/web",
        output: "/electron/app",
      },
      {
        input: "/build/web/public",
        output: "/electron/app",
      },
    ];

    paths.forEach((directory) => {
      fsExtra.emptyDir(path.join(__dirname, directory.output)).then(() => {
        copyDir.sync(
          path.join(__dirname, directory.input),
          path.join(__dirname, directory.output),
          {
            utimes: true, // Keep add time and modify time.
            mode: true, // Keep file mode.
            cover: true, // Cover file when exists, default is true.
          }
        );

        console.log({
          input: path.join(__dirname, directory.input),
          output: path.join(__dirname, directory.output),
        });
      });
    });
  });

program.parse(process.argv);
