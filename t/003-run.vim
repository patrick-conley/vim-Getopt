" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jul 09
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

set filetype=t
silent echo Getopt#Filetype

let test_call = "call Getopt#Run()"

call vimtap#Plan(13)

" Getopt {{{1
" Getopt#Run {{{2
" Run aborts on an invalid filetype (x4) {{{3

" Undef filetype (x2) {{{4
set filetype=

let message = "Filetype module [^ ]* undefined"

call vimtap_except#Lives( test_call, "Run aborts if filetype is unset" )
call vimtap#Like( Getopt#Run(), message, 
         \ "Run recognizes unknown filetype (unset)" )

call Getopt#Saved.Init()

" Unknown filetype (x2) {{{4
set filetype=Getopt_nonesuch_ft

call vimtap_except#Lives( test_call, "Run aborts if filetype is unknown" )
call vimtap#Like( Getopt#Run(), message, 
         \ "Run recognizes unknown filetype (unknown)" )

set filetype=t
call Getopt#Saved.Init()

" Run uses saved FT object if one exists (x1) {{{3
" NB: to test this, the presence of the reused FT object must trigger a known
" exception elsewhere. I use an invalid filetype, as I already know that would
" trigger an error if .New() was called

set filetype=Getopt_nonesuch_ft
let Getopt#Saved.ft_dict.Getopt_nonesuch_ft = {}

call vimtap_except#Unlike( test_call, "Key not present in dictionary: New",
         \ "Run reuses a previously-used FT object if possible" )

call Getopt#Saved.Init()
set filetype=t

" Run loads a new FT object only if unused (x0) {{{3
" NB: FT modules that don't exist are guaranteed to be unused. Tests for that
" condition above cover this case.

" Run aborts cleanly if ft.opt_keys is unset (x0) {{{3
" NB: this should have been tested in Getopt#Filetype.New(). 


" Run aborts cleanly if no data is entered (x2) {{{3

let test_ft = Getopt#Filetype.New()
call test_ft.SetInputList( [] )
call Getopt#Saved.SetFt( 't', test_ft )

call vimtap_except#Lives( test_call, 
         \ "Run does not fail if no data is entered" )
call vimtap#Is( Getopt#Run(), "Getopt: No options entered.",
         \ "Run aborts if no data is entered" )

call Getopt#Saved.Init()

" Run generates expected output for valid input (x6) {{{3

" String output, no globals {{{4
let test_ft = Getopt#Filetype.New( 5, -1, -1, 1 )
call test_ft.Save()

let result = 
         \ "NO GLOBALS\n" .
         \ "local_nodef1: 1\n" .
         \ "local_nodef2: 1\n" .
         \ "local_def: 1\n"

call vimtap#Is( Getopt#Run(), result, "Run works: string output, no globals" )
unlet result

" List output, no globals {{{4
let test_ft = Getopt#Filetype.New( 5, -1, -1, 2 )
call test_ft.Save()

let result = [
         \ "NO GLOBALS",
         \ "local_nodef1: 1",
         \ "local_nodef2: 1",
         \ "local_def: 1" ]

call vimtap#Is( Getopt#Run(), result, "Run works: list output, no globals" )
unlet result

" String output, with globals {{{4
let test_ft = Getopt#Filetype.New( 7, 7, -1, 1 )
call test_ft.Save()

let result = 
         \ "global_nodef1: 1\n" .
         \ "global_nodef2: 1\n" .
         \ "global_def: 1\n" .
         \ "local_nodef1: 1\n" .
         \ "local_nodef2: 1\n" .
         \ "local_def: 1\n"

call vimtap#Is( Getopt#Run(), result, "Run works: string output with globals" )
unlet result

" List output, with globals {{{4
let test_ft = Getopt#Filetype.New( 7, 7, -1, 2 )
call test_ft.Save()

let result = [
         \ "global_nodef1: 1",
         \ "global_nodef2: 1",
         \ "global_def: 1",
         \ "local_nodef1: 1",
         \ "local_nodef2: 1",
         \ "local_def: 1" ]

call vimtap#Is( Getopt#Run(), result, "Run works: list output with globals" )
unlet result

" String output, without locals {{{4
let test_ft = Getopt#Filetype.New( 6, 6, -1, 1 )
call test_ft.Save()

let result = 
         \ "global_nodef1: 1\n" .
         \ "global_nodef2: 1\n" .
         \ "global_def: 1\n" .
         \ "NO LOCALS\n"

call vimtap#Is( Getopt#Run(), result, "Run works: string output without locals" )
unlet result

" List output, without locals {{{4
let test_ft = Getopt#Filetype.New( 6, 6, -1, 2 )
call test_ft.Save()

let result = [
         \ "global_nodef1: 1",
         \ "global_nodef2: 1",
         \ "global_def: 1",
         \ "NO LOCALS" ]

call vimtap#Is( Getopt#Run(), result, "Run works: list output without locals" )
unlet result

