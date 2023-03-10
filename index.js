const fs = require("fs");
const { program } = require("commander");

const main = () => {
  // init Elm app
  const { Elm } = require("./main.js");
  const app = Elm.Main.init({
    flags: null,
  });

  // process args
  program.option("-f, --file <string>").option("-s, --sort <string>");
  program.parse();
  const options = program.opts();

  // check if file is empty or invalid
  const fileName = options?.file;
  const sortOrder = options?.sort || "";

  if (!fileName) throw new Error("Need a file. Use -f <filepath>");

  const data = fs.readFileSync(fileName, "utf-8");

  app.ports.receiveInputs.send([data, sortOrder]);

  app.ports.logSortedImports.subscribe((str) => {
    console.log("\n\n" + str + "\n\n");
    return;
  });
};
main();
