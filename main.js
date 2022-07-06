#!/usr/bin/env node

const program = require("commander");
const package = require("./package.json");

const fs = require("fs");
const path = require("path");
const {
  exec
} = require("child_process");

program.version(package.version);

program
  .command("web-build")
  .description("Compilar builds Web.")
  .action(() => {
    exec("flybis icon-generate", (error, stdout, stderr) => {
      if (error)
        return console.error(error);

      if (stderr)
        return console.error(stderr);


      console.log("📦 FLUTTER ICON GENERATE");
      console.log(stdout);

      exec(
        "flutter build web --release --web-renderer auto",
        (error, stdout, stderr) => {
          if (error)
            return console.error(error);

          if (stderr)
            return console.error(stderr);


          console.log("📦 FLUTTER BUILD");
          console.log(stdout);

          exec("cd react && npm run build", (error, stdout, stderr) => {
            if (error)
              return console.error(error);

            if (stderr)
              return console.error(stderr);


            console.log("📦 REACT BUILD");
            console.log(stdout);

            exec("flybis web-minify", (error, stdout, stderr) => {
              if (error)
                return console.error(error);

              if (stderr)
                return console.error(stderr);


              console.log("📦 WEB MINIFY");
              console.log(stdout);

              exec("flybis web-copy", (error, stdout, stderr) => {
                if (error)
                  return console.error(error);
                if (stderr)
                  return console.error(stderr);


                console.log("📦 WEB COPY");
                console.log(stdout);
              });
            });
          });
        }
      );
    });
  });

program
  .command("web-minify")
  .description("Minimizar javascripts para a build Web.")
  .action(() => {
    const terser = require("terser");
    const folder = "/build/web/";

    fs.readdir(path.join(__dirname, folder), (error, files) => {
      if (error)
        return console.error("Unable to scan directory: ", error);


      files.forEach((file) => {
        if (path.extname(file) == ".js") {
          const location = path.join(__dirname, folder, file);

          fs.promises.readFile(location, "utf-8").then((original) => {
            terser
              .minify(original, {
                compress: true,
                ie8: true,
                keep_classnames: path.basename(file).includes("main") ?
                  false : true,
                keep_fnames: path.basename(file).includes("main") ?
                  false : true,
                mangle: true,
                module: true,
              })
              .then((minify) => {
                fs.writeFile(location, minify.code, (error) => {
                  if (error)
                    return console.error("Unable to minify file: ", error);


                  return console.log({
                    original: `${original.length} Characters`,
                    minify: `${minify.code.length} Characters`,
                    location,
                  });
                });
              });
          });
        }
      });
    });
  });

program
  .command("web-copy")
  .description("Copiar a build Web para os diretórios de distribuição.")
  .action(() => {
    const fsExtra = require("fs-extra");
    const copyDir = require("copy-dir");

    const emptys = ["/public", "/electron/app"];

    const paths = [{
        input: "/react/build",
        output: emptys[0],
      },
      {
        input: "/build/web/public",
        output: emptys[0],
      },
      {
        input: "/build/web",
        output: emptys[0] + "/app",
      },
      {
        input: "/build/web/public",
        output: emptys[1],
      },
      {
        input: "/build/web",
        output: emptys[1],
      },
    ];

    emptys.forEach((empty) => {
      fsExtra.emptyDir(path.join(__dirname, empty)).then(() => {
        paths.forEach((directory) => {
          copy(directory);
        });
      });

      console.log({
        empty
      });
    });

    function copy(directory) {
      copyDir.sync(
        path.join(__dirname, directory.input),
        path.join(__dirname, directory.output), {
          utimes: true, // Keep add time and modify time.
          mode: true, // Keep file mode.
          cover: true, // Cover file when exists, default is true.
        }
      );

      return console.log({
        input: path.join(__dirname, directory.input),
        output: path.join(__dirname, directory.output),
      });
    }
  });

program
  .command("icon-generate")
  .description("Gerar ícones para todas as plataformas.")
  .action(async () => {
    const copyDir = require("copy-dir");

    copyDir.sync(
      path.join(__dirname, "/assets/icons"),
      path.join(__dirname, "/electron/assets/icons"), {
        utimes: true, // Keep add time and modify time.
        mode: true, // Keep file mode.
        cover: true, // Cover file when exists, default is true.
      }
    );

    exec(
      "flutter pub run flutter_launcher_icons:main",
      (error, stdout, stderr) => {
        if (error)
          return console.error(error);

        if (stderr)
          return console.error(stderr);

        console.log("📦 FLUTTER LAUNCHER ICONS");
        console.log(stdout);

        exec(
          "flutter pub run flutter_native_splash:create",
          (error, stdout, stderr) => {
            if (error)
              return console.error(error);

            if (stderr)
              return console.error(stderr);

            console.log("📦 FLUTTER NATIVE SPLASH");
            console.log(stdout);
          }
        );
      }
    );
  });

program.parse(process.argv);