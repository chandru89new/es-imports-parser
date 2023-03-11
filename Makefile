build:
	elm make src/Main.elm --optimize --output main.js

dev-build:
	elm make src/Main.elm --output main.js

test:
	npx elm-test src/Tests.elm