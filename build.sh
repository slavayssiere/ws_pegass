#!/bin/bash

version=$1

cp ./version_tpl.json ./version.json

sed -i.bak s/VERSION/$version/g ./version.json

docker build -t slavayssiere/ws_pegass:$version .


