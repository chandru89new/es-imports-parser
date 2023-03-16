const fs = require("fs");

const main = () => {
  // init Elm app
  const { Elm } = require("./main.js");
  const app = Elm.Main.init({
    flags: null,
  });

  app.ports.elmToNode.subscribe(([type, data]) => {
    switch (type) {
      case "log":
        console.log(`\n${data}\n`);
        break;
      case "get_file_contents":
        try {
          const d = fs.readFileSync(data, "utf-8");
          app.ports.nodeToElm.send(["file_contents", d]);
        } catch (e) {
          console.log(
            `\nCould not read the contents of the file: ${data}. ${e.toString()}`
          );
        }
        break;
      default:
        console.log(
          `\nElm tried to call node to do something with message type = "${type}" but I havent handled it yet.\n`
        );
        break;
    }
  });

  app.ports.nodeToElm.send(["cli_input", process.argv.join(" ")]);
};
main();
