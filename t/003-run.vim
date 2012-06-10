" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 09
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#Run
"
"                Getopt#Run returns v:exception when a known condition causes
"                the program to abort; unexpected exceptions are rethrown
"
" Tests:         - aborts cleanly on unknown filetype
"                - uses saved ft object if it exists
"                - uses new ft object if it doesn't
"                - aborts cleanly if ft.opt_keys is undefined
"                - aborts cleanly if no data is entered
"
"                a number of complete calls
"                Note: from current t/filetype.vim

silent echo Getopt#Filetype

let test_call = "call Getopt#Run()"

call vimtap#Plan(11)

" Getopt {{{1
" Getopt#Run {{{2
" Run aborts on an invalid filetype (x4) {{{3

" Undef filetype (x2) {{{4
set filetype=

let message = "Filetype module [^ ]* undefined"

call vimtap_except#Lives( test_call, "Run aborts if filetype is unset" )
call vimtap#Like( Getopt#Run(), message, 
         \ "Run recognizes unknown filetype (unset)" )

" Unknown filetype (x2) {{{4
set filetype=Getopt_nonesuch_ft

call vimtap_except#Lives( test_call, "Run aborts if filetype is unknown" )
call vimtap#Like( Getopt#Run(), message, 
         \ "Run recognizes unknown filetype (unknown)" )

" Run uses saved FT object if one exists (x1) {{{3
" NB: to test this, the presence of the reused FT object must trigger a known
" exception elsewhere. I use an obviously-invalid .input list (wrong number of
" elements), as that *must* trigger an exception elsewhere

set filetype=t
let test_ft = Getopt#Filetype.New()

" Second key will try to remove an item from the empty list
let test_ft['input'] = [ 1 ]

call Getopt#Saved.SetFt( 't', test_ft )
call vimtap_except#Like( test_call, "E684",
         \ "Run reuses a previously-used FT object if possible" )

call Getopt#Saved.Init()

" Run loads a new FT object only if unused (x0) {{{3
" NB: FT modules that don't exist are guaranteed to be unused. Tests for that
" condition above cover this case.

" Run aborts cleanly if ft.opt_keys is unset (x4) {{{3
" NB: this should already have been tested in Getopt#Filetype.New(). Can't
" hurt to double up…

" opt_keys undefined (x2) {{{4
let test_ft = Getopt#Filetype.New()
unlet test_ft.opt_keys
call Getopt#Saved.SetFt( 't', test_ft )

call vimtap_except#Lives( test_call, 
         \ "Run does not fail if opt_keys is unset (undefined)" )
call vimtap#Is( Getopt#Run(), 
         \ "Getopt: No option information is defined. Nothing to do",
         \ "Run aborts if opt_keys is unset (undefined)" )

" opt_keys empty (x2) {{{4
let test_ft = Getopt#Filetype.New()
let test_ft.opt_keys = []
call Getopt#Saved.SetFt( 't', test_ft )

call vimtap_except#Lives( test_call, 
         \ "Run does not fail if opt_keys is unset (empty)" )
call vimtap#Is( Getopt#Run(), 
         \ "Getopt: No option information is defined. Nothing to do",
         \ "Run aborts if opt_keys is unset (empty)" )
" }}}4

call Getopt#Saved.Init()

" Run aborts cleanly if no data is entered (x2) {{{3
let test_ft = Getopt#Filetype.New()
call test_ft.SetInputList( [] )
call Getopt#Saved.SetFt( 't', test_ft )

call vimtap_except#Lives( test_call, 
         \ "Run does not fail if no data is entered" )
call vimtap#Is( Getopt#Run(), "Getopt: No options entered. Nothing to do.",
         \ "Run aborts if no data is entered" )

call Getopt#Save.Init()
