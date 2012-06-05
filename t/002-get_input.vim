" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 05
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#Filetype
"
"                Filetype.SetInputList() sets Filetype.input
"                Filetype.SetInputList() fails if  argument is not a list
"                _Get_input() fails if  opt_keys is not defined
"                _Get_input() passes valid per-opt data 
"                _Get_input() ignores invalid per-opt data
"                _Get_input() passes valid global data
"                _Get_input() fails on on invalid global data

set filetype=t
silent echo Getopt#Filetype

call vimtap#Plan(23)

" Getopt#Filetype (x4) {{{1
" Getopt#Filetype.SetInputList() (x4) {{{2

let test_ft = Getopt#Filetype.New()

call vimtap_except#Lives( "call g:test_ft.SetInputList( [ 1, 2 ] )",
         \ "Filetype.SetInputList() runs" )

call vimtap#Is( test_ft.input, [ 1, 2 ], "Filetype.SetInputList() sets .input" )
call vimtap_except#Like( "call g:test_ft.SetInputList( '' )", "^Getopt#Filetype",
         \ "Filetype.SetInputList fails on non-list input (string)" )
call vimtap_except#Like( "call g:test_ft.SetInputList( {} )", "^Getopt#Filetype",
         \ "Filetype.SetInputList fails on non-list input (hash)" )
" Getopt (x19) {{{1
" Getopt#_Get_input (x19) {{{2

let test_ft = Getopt#Filetype.New()
let test_call = "call Getopt#_Get_input( g:test_ft )"

" _Get_input fails if given an unclean Filetype object (x3) {{{3
let exception = "Getopt: Unclean Filetype object passed to _Get_input()"

let test_ft.opt_data = [ 1 ]
call vimtap_except#Is( test_call, exception, 
         \ "_Get_input fails if opt_data is not empty" )

let test_ft.opt_data = []
let test_ft.global_data = [ 1 ]
call vimtap_except#Is( test_call, exception,
         \ "_Get_input fails if global_data is not empty" )

let test_ft.opt_data = [ 1 ]
call vimtap_except#Is( test_call, exception,
         \ "_Get_input fails if opt_data and global_data are not empty" )

let test_ft.opt_data = []
let test_ft.global_data = []

" _Get_input fails if non-interactive input is invalid (x2) {{{3
let exception =  "Getopt: Invalid non-interactive input"

" NB: this failure can occur either in .SetInputList or _Get_input
try
   call test_ft.SetInputList( [] )
   call Getopt#_Get_input( test_ft )
   call vimtap#Fail( "_Get_input fails if non-interactive input list is empty" )
catch
   call vimtap#Is( v:exception, exception,
            \ "_Get_input fails if non-interactive input list is empty" )
endtry

" NB: should not be set manually; should have been tested for by
" Filetype.SetInputList()
let test_ft.input = 'a'
call vimtap_except#Is( test_call, exception,
         \ "_Get_input fails if non-interactive input is non-list" )

call test_ft.SetInputList( [ 1, 1, 1 ] )

" _Get_input fails if opt_keys is unset (x1) {{{3
" NB: Filetype.New shouldn't pass a ft module that doesn't set opt_keys
let exception =  "Getopt: No option information is defined. Nothing to do"
let test_ft.opt_keys = []

call vimtap_except#Is( test_call, exception,
         \ "_Get_input() fails without Filetype.opt_keys" )

let test_ft = Getopt#Filetype.New()

" _Get_input passes valid per-opt data (x4) {{{3
" Single item
call test_ft.SetInputList( [ 'a', 'b', 4 ] )
let result = [ { 'local_nodef1': 'a', 'local_nodef2': 'b', 'local_def':4 } ]

call vimtap_except#Lives( test_call, "_Get_input() passes valid local input" )
call vimtap#Is( test_ft.opt_data, result, "_Get_input sets valid local input" )
let test_ft = Getopt#Filetype.New()

" Several items
call test_ft.SetInputList( [ 'a', 'b', 0, 1, 2, 'c', '', 3, '' ] )
let result = [ { 'local_nodef1': 'a', 'local_nodef2': 'b', 'local_def': 0 },
             \ { 'local_nodef1': 1, 'local_nodef2': 2, 'local_def': 'c' },
             \ { 'local_nodef1': '', 'local_nodef2': 3, 'local_def': '' } ]

call vimtap_except#Lives( test_call, 
         \ "_Get_input() passes valid local input (several items)" )
call vimtap#Is( test_ft.opt_data, result, 
         \ "_Get_input sets valid local input (several items)" )
let test_ft = Getopt#Filetype.New()

" _Get_input ignores invalid per-opt data (x6) {{{3
" Single item (does not set a required key)
call test_ft.SetInputList( [ '', '', '' ] )
let result = []

call vimtap_except#Lives( test_call, 
         \ "_Get_input() passes invalid local input (unset req'd key)" )
call vimtap#Is( test_ft.opt_data, result,
         \ "_Get_input() ignores invalid local input (unset req'd key)" )
let test_ft = Getopt#Filetype.New()

" Single item (incorrectly sets numeric key)
call test_ft.SetInputList( [ '', 2, 2 ] )
let result = []

call vimtap_except#Lives( test_call, 
         \ "_Get_input() passes invalid local input (incorrect key)" )
call vimtap#Is( test_ft.opt_data, result,
         \ "_Get_input() ignores invalid local input (incorrect key)" )
let test_ft = Getopt#Filetype.New()

" Multiple items (fail, pass, fail, pass, fail)
call test_ft.SetInputList( 
         \ [ '', '', '',  '', 1, 1,  '', 2, 2,  '', 3, 3,  '', '', 2 ] )
let result = [ { 'local_nodef1': '', 'local_nodef2': 1, 'local_def': 1 },
             \ { 'local_nodef1': '', 'local_nodef2': 3, 'local_def': 3 } ]

call vimtap_except#Lives( test_call, 
         \ "_Get_input() passes invalid local input (several items)" )
call vimtap#Is( test_ft.opt_data, result,
         \ "_Get_input() ignores invalid local input (several items)" )
let test_ft = Getopt#Filetype.New()

" _Get_input passes valid global data (x2) {{{3
let g:Getopt_var_flags = 3
let g:Getopt_func_flags = 3
let test_ft = Getopt#Filetype.New()

call test_ft.SetInputList( [ '', 1, 1,  '', 1, 1 ] )

unlet result
let result = { 'global_nodef1': '', 'global_nodef2': 1, 'global_def': 1 }

call vimtap_except#Lives( test_call, "_Get_input() passes valid global input" )
call vimtap#Is( test_ft.global_data, result, 
         \ "_Get_input sets valid global input" )
let test_ft = Getopt#Filetype.New()

" _Get_input fails invalid global data (x1) {{{3
call test_ft.SetInputList( [ '', '', 1 ] )

call vimtap_except#Is( test_call, "Getopt: Invalid global data entered",
         \ "_Get_input() fails invalid global input" )
