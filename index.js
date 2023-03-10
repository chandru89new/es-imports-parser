const { execSync } = require("child_process");
execSync("elm make src/Main.elm --output main.js");
const { Elm } = require("./main.js");
const app = Elm.Main.init({
  flags: null,
});
const fs = require("fs");
console.log(process.argv);
app.ports.readImportsString.subscribe((fileName) => {
  const data = fs.readFileSync(`./${fileName}`, "utf-8");
  app.ports.receiveImportsString.send(data);
});
app.ports.saveSortedString.subscribe((string) => {
  console.log("\nSorted string:\n");
  console.log(string);
});
