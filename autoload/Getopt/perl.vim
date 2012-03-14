" Getopt/perl    Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 13
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

function Getopt#perl#init()
   if &ft !~ "perl"
      throw "Getopt#perl#init called from outside a Perl script"
   endif
endfunc

function! Getopt.declare() dict
   return
endfunc

function! Getopt.validate() dict
	" nb: will want name, optional/default, type
	" nb: if nothing has name, use validate_pos; if everything has name, use
	" validate
   return
endfunc

function! Getopt.validate_global(D) dict
   " nb: will want opt_list
   return
endfunc

function! Getopt.write() dict
   return
endfunc

