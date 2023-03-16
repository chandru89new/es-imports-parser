# ES6 Imports Sorter

Experimental ES6 import order sorter. Very limited / constricted functionality. Built as a way to understand the [Elm Parser](https://package.elm-lang.org/packages/elm/parser/latest/Parser).

At this time, it does not modify the file. It simply outputs the correct import order string (that you can copy/paste).

## To run from source

```
# install elm globally so you can compile the
$ brew install elm # or `npm i -g elm`
$ make 

# now just run the index.js file in node
$ node index.js --file <file_path>
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

## Modify / Test

These files contain the logic of the program:

```
- src/ImportParser.elm # the parsing logic
- src/Sorter.elm # the sorting logic
- src/Main.elm # the actual app which talks to the node as a Platform.worker - (https://package.elm-lang.org/packages/elm/core/latest/Platform#worker)
```

Tests are in `src/Tests.elm`. To run tests:

I am assuming you have [npx](https://www.npmjs.com/package/npx) installed because this uses it.
``` 
$ make test
```

**Note:**
Because [`Parser.deadEndsToString`](https://github.com/elm/parser/blob/master/src/Parser.elm#L169) is a TODO at this time, the script uses `Debug.toString` and therefore compiles only in DEV mode.