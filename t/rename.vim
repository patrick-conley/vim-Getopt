" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 23
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       Test cases to check Getopt.rename_for_input() works properly

call vimtap#Plan(4)

let tests = [ 'foo', 'foo_bar', 'has', 'has_foo' ]
let results = [ 'foo', 'foo bar', 'has?', 'has foo?' ]

for iTest in range(len(tests))
   let output = Getopt.rename_for_input( tests[iTest] )

   call vimtap#Is( output, results[iTest], 
            \ "rename works on \"" . tests[iTest] . "\"" )
endfor
