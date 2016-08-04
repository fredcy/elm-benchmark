build: elm.js

elm.js: Main.elm ../src/Benchmark.elm ../src/Native/Benchmark.js
	elm make --yes Main.elm --output=elm.js
