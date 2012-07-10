" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jul 09
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#Filetype

set filetype=t
silent echo Getopt#Filetype

call vimtap#Plan(14)

" Getopt#Filetype {{{1
" Getopt#Filetype.New() (x3) {{{2

" fails on unset .opt_keys and .global_keys
call vimtap_except#Like( "call g:Getopt#Filetype.New( 0, -1, -1, -1 )", 
         \ "^Getopt#Filetype",
         \ "Filetype.New() fails if ft module doesn't set .opt_keys or global_keys" )

call vimtap_except#Lives( "call g:Getopt#Filetype.New( 1, -1, -1, -1 )",
			\ "Filetype.New() lives if ft module sets .opt_keys" )
call vimtap_except#Lives( "call g:Getopt#Filetype.New( 2, 6, -1, -1 )",
			\ "Filetype.New() lives if ft module sets .global_keys" )

" Getopt#Filetype.Compare() (x6) {{{2

" .Compare() runs
call vimtap_except#Lives( "call g:Getopt#Filetype.Compare( {} )",
         \ "Filetype.Compare() runs" )

" Check results: empty hash
let test_ft = {}
call vimtap#Is( Getopt#Filetype.Compare( test_ft ), 0, 
         \ "Filetype.Compare returns correctly (false - empty hash)" )

" FT object
let test_ft = Getopt#Filetype.New()
call vimtap#Is( Getopt#Filetype.Compare( test_ft ), 1, 
         \ "Filetype.Compare() returns correctly (true - FT object)" )

" FT object with globals
let test_ft = Getopt#Filetype.New( 7, 7, -1, -1 )
call vimtap#Is( Getopt#Filetype.Compare( test_ft ), 1, 
         \ "Filetype.Compare() returns correctly (true - FT object with Validate_global)" )

" FT object with an incorrectly-typed member
unlet test_ft.Validate
let test_ft.Validate = [ 1 ]
call vimtap#Is( Getopt#Filetype.Compare( test_ft ), 0, 
         \ "Filetype.Compare() returns correctly (false - incorrect type)" )

" FT object missing a member
unlet test_ft.Validate
call vimtap#Is( Getopt#Filetype.Compare( test_ft ), 0,
         \ "Filetype.Compare() returns correctly (false - missing member)" )

" Getopt#Filetype.HasData() (x5) {{{2
let test_ft = Getopt#Filetype.New()

call vimtap_except#Lives( "call g:test_ft.HasData()", "Filetype.HasData() runs" )
call vimtap#Is( test_ft.HasData(), 0, 
         \ "Filetype.HasData() fails (no data)" )

let test_ft.opt_data = [ 1, 2 ]
call vimtap#Is( test_ft.HasData(), 1,
         \ "Filetype.HasData() succeeds (opt_data defined)" )

let test_ft = Getopt#Filetype.New( 3, 7, -1, -1 )

let test_ft.opt_data = [ 1, 2 ]
call vimtap#Is( test_ft.HasData(), 0,
         \ "Filetype.HasData() fails (global_keys but no global_data)" )

let test_ft.global_data = { 'a':1 }
call vimtap#Is( test_ft.HasData(), 1,
         \ "Filetype.HasData() succeeds (global_keys)" )

