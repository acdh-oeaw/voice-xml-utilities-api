#!/bin/bash
# Run this script to update the VICAV instance to the latest versions. 
# It ...
# * pulls the current code of the web application from github.
# * pulls the current content of the web application from github.

onlytags=false
if [ -f redeploy.settings ]
then . redeploy.settings
fi

if [ -d webapp/voice-basex-api ]
then
#------ Update XQuery code -----------
echo Updating voice-basex-api
pushd webapp/voice-basex-api
git pull
ret=$?
if [ $ret != "0" ]; then exit $ret; fi
if [ "$onlytags"x = 'truex' ]
then
uiversion=$(git describe --tags --always)
echo checking out UI ${uiversion}
git -c advice.detachedHead=false checkout ${uiversion}
find ./ -type f -and \( -name '*.xq' -or -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@version@~$uiversion~g" {} \;
fi
git checkout master
popd
fi
#-------------------------------------

./execute-basex-batch.sh deploy-voice-content