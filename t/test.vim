" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Apr 02
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       Test cases to check Getopt.test() runs properly

" aborts cleanly when called on unknown filetype
" runs autoload when called on recognized filetype (t_test)
" 
" aborts if any function doesn't exist
"
" declare() runs
" aborts cleanly if declare() doesn't run
"
" all functions require correct number of args
"
" passes correct opt_data
" fails incorrect opt_data
"
" fails validates that allow empty input

" FIXME: apparently I can't use VimTAP to test a function that's based on
" VimTAP. Who knew…
