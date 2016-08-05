#!/bin/bash

set -o errexit -o nounset

if [ "$TRAVIS_BRANCH" != "master" ]
then
    echo "This commit was made against the $TRAVIS_BRANCH and not the master! No deploy!"
    exit 0
fi

rev=$(git rev-parse --short HEAD)

cd example

git init
git config user.name "Fred Yankowski"
git config user.email "fcy@imsa.edu"

git remote add upstream "https://$GH_TOKEN@github.com/fredcy/elm-benchmark.git"
git fetch upstream
git reset upstream/gh-pages

touch .

git add -A index.html elm.js
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages
