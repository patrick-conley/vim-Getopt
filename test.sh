#!/bin/bash

# Author:        Patrick Conley <patrick.bj.conley@gmail.com>
# Last Changed:  2012 Mar 26
# License:       This plugin (and all assoc. files) are available under the
#                same license as Vim itself.
# Summary:       Wrapper for unit tests

for iFile in $( ls t/*.vim )
do
   echo $iFile
   vtruntest.sh $iFile
done
