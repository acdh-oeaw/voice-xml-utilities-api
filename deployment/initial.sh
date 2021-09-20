#!/bin/bash
cp -Rv ./deployment/* ../../
if [ -f package.json ]
then npm install
fi
cd ../
git clone https://github.com/acdh-oeaw/openapi4restxq.git -b master_basex
cd ../
if [ -f redeploy.settings.dist ]
then mv redeploy.settings.dist redeploy.settings
fi
curl -O --header "PRIVATE-TOKEN: q3_c-GvQ_sV6upEw1xJE" "https://gitlab.com/api/v4/projects/21073173/repository/archive.tar"
tar -xf archive.tar
rm archive.tar
mv voice_data* voice_data
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