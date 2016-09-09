build: elm.js

elm.js: Main.elm ../src/Stats.elm ../src/Benchmark.elm ../src/Native/Benchmark.js
	elm package install --yes
	elm make --yes Main.elm --output=elm.js
