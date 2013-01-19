#!/bin/sh
# Heath Behrens 09/08/2011 - updated to work from current directory not hardcoded home directory
DEBUG=upstage.client.App.debug
#DEBUG=no

BASE_DIR=.

cd $BASE_DIR/client/src
mtasc -version 10 -msvc -wimp -strict -frame 1 -header 320:200:30 \
    -trace $DEBUG -swf classes.swf upstage/client/App.as \
    || exit


echo '*** compiled OK ***'

# Link classes.swf to symbol in client.swf 
# Also embedd fonts to client.swf
echo
echo '*** Linking with swfmill ***'
echo
swfmill simple upstage/client/application.xml client.swf
echo 'Classes size is:'
ls -s --block-size=1 classes.swf
echo 'Client size is:'
ls -s --block-size=1 client.swf
echo
cd ../../
cp client/src/classes.swf client/src/client.swf  html/swf/