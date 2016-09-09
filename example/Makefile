CONTEXT =

build: elm.js

elm.js: Main.elm ../src/Benchmark/Stats.elm ../src/Benchmark.elm ../src/Benchmark/Program.elm ../src/Native/Benchmark.js
	$(CONTEXT) elm package install --yes
	$(CONTEXT) elm make --yes Main.elm --output=elm.js
