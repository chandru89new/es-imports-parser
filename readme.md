# ES6 Imports Sorter

Experimental ES6 import order sorter. Built as a way to understand the [Elm Parser](https://package.elm-lang.org/packages/elm/parser/latest/Parser).

**Warning**: This script over-writes files.

## To run

```
# install elm globally so you can compile the
$ brew install elm # or `npm i -g elm`
$ make 

# now just run the index.js file in node
$ node index.js --file <file_path>

$ node index.js --help # show help/usage information.
```

## Custom sort order

```
$ node index.js --file <file_path> --sort defaults,objects,none,asterix
```

## Sort order meaning:

Available options:

```
- defaults // import Default from "somewhere"; OR import Default, { AndThatThing } from "somewhere";
- objects // import { theThing, orOtherThing } from "somewhere";
- none // import "globally.css";
- asterix // import * as something from "somewhere";
```

**Note**: If you want to specify a custom order (using the `--sort` option), you have to mention all four options in the order you want.

**These are the only valid import strings this tool can parse:**

```
import Something from "somewhere";
import SomethingToo, { anotherThing } from "elsewhere";
import { theThing, OrThatThing } from "../../wherever.js";
import "../whatever.css";
import * as sayWhat from "everywhere";
import { 
  A,
  B,
  C,
} from "D";
```

## Dry-run

Don't want the script to "fix"/overwrite files? Use the `--dry-run` flag.

```bash
node index.js --file /some/file.js --sort "defaults,asterix,objects,none" --dry-run
```

This will output the final "fixed" content to the console.

**Note:**
Because [`Parser.deadEndsToString`](https://github.com/elm/parser/blob/master/src/Parser.elm#L169) is a TODO at this time, the script uses `Debug.toString` and therefore compiles only in DEV mode.