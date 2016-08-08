build: elm.js

elm.js: Main.elm ../src/Benchmark.elm ../src/Native/Benchmark.js
	find . -type f -ls
	elm package install --yes
	find . -type f -ls
	elm make --yes Main.elm --output=elm.js
	find . -type f -ls
