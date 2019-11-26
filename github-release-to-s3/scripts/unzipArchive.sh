# !/usr/bin/env sh
set -e

inputJSON=$(cat)

archive=$(echo $inputJSON | jq -r .archive)
destination=$(echo $inputJSON | jq -r .destination)

mkdir -p $destination

unzip -u $archive -d $destination >> /dev/null

jq -n "{ destination: \"$destination\" }"
