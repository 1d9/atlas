# !/usr/bin/env sh
set -e

inputJSON=$(cat)

repo=$(echo $inputJSON | jq -r .repo)
release=$(echo $inputJSON | jq -r .release)
file=$(echo $inputJSON | jq -r .file)

url="https://github.com/$repo/releases/download/$release/$file"

wget $url -O $file >> /dev/null

jq -n "{ file: \"$file\" }"
