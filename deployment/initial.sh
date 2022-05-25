#!/bin/bash
cp -Rv ./deployment/* ${1:-../../}
if [ -f package.json ]
then npm install
fi
cd ${1:-../..}/webapp
git clone https://github.com/acdh-oeaw/openapi4restxq.git -b master_basex
cd ../
if [ -f redeploy.settings.dist ]
then mv redeploy.settings.dist redeploy.settings
fi
node collection_download_script.cjs --flat --targetDir voice-data/xml
if [ "${STACK}x" == "x" ]; then
pushd lib/custom
curl -LO https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/11.3/Saxon-HE-11.3.jar
curl -LO https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/4.3.0/xmlresolver-4.3.0.jar
popd
if [ "$OSTYPE" == "msys" -o "$OSTYPE" == "win32" ]
then
  cd bin
  start basexhttp.bat
else
  cd bin
  ./basexhttp &
fi
cd ..
fi
cd ${1:-.}
if [ "$1"x != 'x' ]
then export USERNAME=admin; export PASSWORD=admin
fi
exec ./redeploy.sh $1