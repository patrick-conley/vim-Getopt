" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 04
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#Filetype
"                Filetype.New() throws exception on unset ft.opt_keys
"                Filetype.HasData() returns true if data has been entered into
"                    ft.opt_data and (if appropriate) ft.global_data

set filetype=t
silent echo Getopt#Filetype

call vimtap#Plan(6)

" Getopt#Filetype {{{1
" Getopt#Filetype.New() (x1) {{{2

" fails on unset .opt_keys
let g:Getopt_var_flags = 0
call vimtap_except#Like( "call g:Getopt#Filetype.New()", "^Getopt#Filetype",
         \ "Filetype.New() fails if ft plugin doesn't set .opt_keys" )
let g:Getopt_var_flags = 1 

" Getopt#Filetype.HasData() (x5) {{{2
let test_ft = Getopt#Filetype.New()

call vimtap_except#Lives( "call g:test_ft.HasData()", "Filetype.HasData() runs" )
call vimtap#Is( test_ft.HasData(), 0, 
         \ "Filetype.HasData() fails (no data)" )

let test_ft.opt_data = [ 1, 2 ]
call vimtap#Is( test_ft.HasData(), 1,
         \ "Filetype.HasData() succeeds (opt_data defined)" )

let g:Getopt_var_flags = 3
let test_ft = Getopt#Filetype.New()

let test_ft.opt_data = [ 1, 2 ]
call vimtap#Is( test_ft.HasData(), 0,
         \ "Filetype.HasData() fails (global_keys but no global_data)" )

let test_ft.global_data = { 'a':1 }
call vimtap#Is( test_ft.HasData(), 1,
         \ "Filetype.HasData() succeeds (global_keys)" )

