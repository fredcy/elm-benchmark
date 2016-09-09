build: elm.js

elm.js: Main.elm ../src/Benchmark/Stats.elm ../src/Benchmark.elm ../src/Benchmark/Program.elm ../src/Native/Benchmark.js
	elm package install --yes
	elm make --yes Main.elm --output=elm.js
