" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 May 21
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#_Rename_for_input
"                - run a variety of key names and compare to known results

set filetype=t
silent echo Getopt#Filetype

call vimtap#Plan(5)

call vimtap_except#Lives( "call Getopt#_Rename_for_input('')",
         \ "_Rename_for_input runs" )

let tests = [ 'foo', 'foo_bar', 'has', 'has_foo' ]
let results = [ 'foo', 'foo bar', 'has?', 'has foo?' ]

for iTest in range(len(tests))
   call vimtap#Is( Getopt#_Rename_for_input( tests[iTest] ), results[iTest], 
            \ "rename works ('" . tests[iTest] . "')" )
endfor
