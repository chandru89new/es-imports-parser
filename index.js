const fs = require("fs");

const writeFile = ({ FilePath, content, numLines }) => {
  try {
    const raw = fs.readFileSync(FilePath, "utf-8");
    const split = raw.split("\n").slice(numLines).join("\n");
    const final = content + "\n\n" + split;
    fs.writeFileSync(FilePath, final);
    console.log("Done.");
  } catch (e) {
    console.log(e.toString());
  }
};

const main = () => {
  // init Elm app
  const { Elm } = require("./main.js");
  const app = Elm.Main.init({
    flags: null,
  });

  app.ports.fromElm.subscribe(([type, data]) => {
    switch (type) {
      case "LogToConsole":
        console.log(`\n${data}\n`);
        break;
      case "ReadFile":
        try {
          const d = fs.readFileSync(data, "utf-8");
          app.ports.toElm.send(["ReceiveFileContents", d]);
        } catch (e) {
          console.log(
            `\nCould not read the contents of the file: ${data}. ${e.toString()}`
          );
        }
        break;
      case "WriteToFile":
        // console.log(data);
        writeFile(data);
        break;
      default:
        console.log(
          `\nElm tried to call node to do something with message type = "${type}" but I havent handled it yet.\n`
        );
        break;
    }
  });

  app.ports.toElm.send(["ReceiveCLICommand", process.argv.join(" ")]);
};
main();
