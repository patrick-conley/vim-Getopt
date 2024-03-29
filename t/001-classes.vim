" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 20
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Basic tests that classes run properly.
"
"                Filetype.New() runs
"                Filetype.New() returns a Filetype object
"                Filetype.Init() runs
"                Filetype.Init() resets members
"                
"                Saved.Init() runs
"                Saved.Init() empties .ft_dict

set filetype=t
silent echo Getopt#Filetype 

call vimtap#Plan(7)

" Getopt#Filetype (x5) {{{1
" Getopt#Filetype.New() (x3) {{{2

" .New runs/fails as appropriate
call vimtap_except#Lives( "call g:Getopt#Filetype.New()",
         \ "Filetype.New() runs (no arg)" )

set filetype=nonesuch
call vimtap_except#Like( "call g:Getopt#Filetype.New()", "^Getopt#Filetype: ",
         \ "Filetype.New() dies on unmatched filetype" )

set filetype=t

" .New creates a Filetype object
let test_ft = Getopt#Filetype.New()

" Check if test_ft is a superset of some critical functions and variables
" (ie., that test_ft is an object derived in some way from Getopt#Filetype)
let filetype_keys = [ "Validate", "Write", "HasData", "Save", "opt_keys", "opt_data" ]
call filter( filetype_keys, '! has_key( test_ft, v:val )' )

call vimtap#Is( filetype_keys, [], "Filetype.New() returns a Filetype object" )

" Getopt#Filetype.Init() (x2) {{{2
let test_ft.global_keys = [ 'foo', 'bar' ]

call vimtap_except#Lives( "call g:Getopt#Filetype.Init( g:test_ft )", 
         \ "Filetype.Init() runs" )
call vimtap#Is( test_ft.global_keys, [], 
         \ "Filetype.Init() resets member variables" )
" Getopt#Saved (x2) {{{1
" Getopt#Saved.Init() (x2) {{{2
let Getopt#Saved.ft_dict.foo = {}

" .Init runs and empties .ft_dict
call vimtap_except#Lives( "call g:Getopt#Saved.Init()", "Saved.Init() runs" )
call vimtap#Is( Getopt#Saved.ft_dict, {}, "Saved.Init() clears Saved.ft_dict" )
