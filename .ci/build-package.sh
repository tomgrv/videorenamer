#!/bin/bash

set -x
set -e

# move build files into source dir
mkdir -p /toolkit/source
cp -R $GITHUB_WORKSPACE /toolkit/source/videorenamer

# grap the node.js binary
cd /toolkit/source/videorenamer
NODE_LTS="$(curl -s https://nodejs.org/dist/index.json | jq -r 'map(select(.lts))[0].version')"
wget https://nodejs.org/dist/$NODE_LTS/node-$NODE_LTS-linux-x64.tar.gz -O node-linux-x64.tar.gz

# build spk
/toolkit/pkgscripts-ng/PkgCreate.py -p braswell -c videorenamer

# copy spk to github workspace
cp /toolkit/build_env/ds.braswell-7.0/image/packages/videorenamer-braswell-$SPK_PACKAGE_VERSION.spk $GITHUB_WORKSPACE/videorenamer-$SPK_PACKAGE_VERSION.spk
