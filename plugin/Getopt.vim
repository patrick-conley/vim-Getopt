" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Apr 27
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt

if exists( "g:loaded_Getopt" ) || &cp
   finish
endif
let loaded_Getopt = 1

" Define the command
if !exists( ":Getopt" )
   command -nargs=0 Getopt echo Getopt#Run()
endif

if !exists( ":Getopttest" )
   command -nargs=0 Getopttest call Getopt#Test(1)
endif

