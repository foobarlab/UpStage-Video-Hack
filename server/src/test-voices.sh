#!/bin/bash
# script to test all configured voices
# writes result to a temporary folder

TEXT='hello world'
TMPDIR=`mktemp -d`
for i in $( ls config/voices); do
  echo found voice-script: $i
  echo $TEXT | config/voices/$i $TMPDIR/$i.mp3
done
echo written voice test files to $TMPDIR