#!/bin/bash
# Run this script to update the VICAV instance to the latest versions. 
# It ...
# * pulls the current code of the web application from github.
# * pulls the current content of the web application from github.

onlytags=false
if [ -f redeploy.settings ]
then . redeploy.settings
fi

#------ Update XQuery code -----------
echo Updating voice-clariah-api
pushd webapp/voice-clariah-api
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
#-------------------------------------

#------ Update content data from git repository
echo Updating voice_data
pushd voice_data
git pull
ret=$?
if [ $ret != "0" ]; then exit $ret; fi
if [ "$onlytags"x = 'truex' ]
then
dataversion=$(git describe --tags --always)
echo checking out data ${dataversion}
git -c advice.detachedHead=false checkout ${dataversion}
who=$(git show -s --format='%cN')
when=$(git show -s --format='%as')
message=$(git show -s --format='%B')
revisionDesc=$(sed ':a;N;$!ba;s/\n/\\n/g' <<EOF
<revisionDesc>
  <change n="$dataversion" who="$who" when="$when">
$message
   </change>
</revisionDesc>
EOF
)
fi
git checkout master
popd
if [ "$onlytags"x = 'truex' ]
then
pushd webapp/voice-clariah-api
find ./ -type f -and \( s-name '*.xq' -or -name '*.js' -or -name '*.html' \) -not \( -path './node_modules/*' -or -path './cypress/*' \) -exec sed -i "s~\@data-version@~$dataversion~g" {} \;
popd
fi
./execute-basex-batch.sh deploy-voice-content
pushd voice_data
git reset --hard
popd