#!/bin/bash
cp -Rv ./deployment/* ../../
if [ -f package.json ]
then npm install
fi
cd ../
git clone https://github.com/acdh-oeaw/openapi4restxq.git -b master_basex
cd ../
if [ -f redeploy.settings.dist ]
then mv redeploy.settings.dist redeploy.settings
fi
git clone git@gitlab.com:acdh-oeaw/voice/voice_data.git
pushd lib/custom
curl -LO https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/10.5/Saxon-HE-10.5.jar
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
exec ./redeploy.sh