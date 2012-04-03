#!/bin/bash

# Author:        Patrick Conley <patrick.bj.conley@gmail.com>
# Last Changed:  2012 Apr 02
# License:       This plugin (and all assoc. files) are available under the
#                same license as Vim itself.
# Summary:       Wrapper for unit tests

testfiles=( 'filetype.vim' 'data.vim' 'rename.vim' 'full.vim' )

for iFile in ${testfiles[@]}
do
   echo t/$iFile
   vtruntest.sh t/$iFile
done
