" Getopt/c:      Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 29
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

function Getopt#c#init()
   if &ft !~ "c"
      throw "Getopt#c#init called from outside a C file"
   endif
endfunc

function! Getopt.declare() dict
   return
endfunc

function! Getopt.validate(D) dict
   " nb: will want name and/or short name, has_arg, def_arg(?)
   return
endfunc

function! Getopt.validate_global(D) dict
   " nb: will want opt_array, opt_num
   return
endfunc

function! Getopt.write() dict
   return
endfunc
