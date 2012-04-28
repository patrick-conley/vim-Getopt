" Getopt/c:      Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Apr 27
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

let Getopt#c#ft = {}

function Getopt#c#ft.New() dict
   let harness = copy( self )

   let harness.opt_keys = []
   let harness.global_keys = []

   return harness
endfunc

function Getopt#c#ft.Validate(D) dict
   " nb: will want name and/or short name, has_arg, def_arg(?)
   return
endfunc

function Getopt#c#ft.Validate_global(D) dict
   " nb: will want opt_array, opt_num
   return
endfunc

function Getopt#c#ft.Write() dict
   return
endfunc
