" Getopt/matlab: Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 13
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

" init function to load the internal methods into g:Getopt
function Getopt#matlab#init()

   if &ft !~ "matlab"
      throw "Getopt#matlab#init called from outside a Matlab file"
   endif
endfunc

function! Getopt.declare() dict
   return
endfunc

function! Getopt.validate() dict
   " nb: will want name, (var_name), has_arg, def_arg(?)
   return
endfunc

function! Getopt.validate_global(D) dict
   " nb: will want opt_list(?)
   return
endfunc

function! Getopt.write() dict
   return
endfunc
