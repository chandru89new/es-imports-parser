# ES6 Imports Sorter

Experimental ES6 import order sorter. Very limited / constricted functionality. Built as a way to understand the [Elm Parser](https://package.elm-lang.org/packages/elm/parser/latest/Parser).

At this time, it does not modify the file. It simply outputs the correct import order string (that you can copy/paste).

## To run

```
$ yarn install # one-time step
$ yarn build # one-time step

$ yarn sort --file <file_path>
```

## Custom sort order

```
$ yarn sort --file <file_path> --sort defaults,objects,none,asterix
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

## Caveats

**No spaces between imports.**

Wrong:
```
import A from "A";

import B from "B";
```

Right:
```
import A from "A";
import B from "B";
```

**One or more lines of separation between imports and rest of the content.**

Wrong:
```
import A from "A";
const b = A.b()
```

Right:
```
import A from "A";

const b = A.b()
```

**All imports must be grouped to the top of the file.**

Wrong:
```
import Something from "A";

Something()
console.log("A")

import Another from "B":
```

Right:
```
import Something from "A";
import Another from "B":

Something()
console.log("A")
```

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

These files contain the log of the program:

```
- src/ImportParser.elm # the parsing logic
- src/Sorter.elm # the sorting logic
- src/Main.elm # the actual app which talks to the node as a [Platform.worker](https://package.elm-lang.org/packages/elm/core/latest/Platform#worker)
```

Tests are in `src/Tests.elm`. To run tests:

```
$ yarn test
```