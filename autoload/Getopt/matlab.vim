" Getopt/matlab: Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Apr 27
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

let Getopt#matlab#ft = {}

function Getopt#matlab#ft() dict

endfunc

function Getopt#matlab#ft.Validate(D) dict
   " nb: will want name, (var_name), has_arg, def_arg(?)
   return
endfunc

function Getopt#matlab#ft.Validate_global(D) dict
   " nb: will want opt_list(?)
   return
endfunc

function Getopt#matlab#ft.Write() dict
   return
endfunc
