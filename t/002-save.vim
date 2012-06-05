" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 04
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt-internal.txt
" Summary:       Test cases on Getopt#Saved
" 
"                Saved.SetFt() passes Filetype objects
"                Saved.SetFt() happily clobbers pre-existing filetypes
"                Saved.SetFt() fails non-hashes (list, string)
"                Saved.SetFt() fails non-Filetype objects
"                Saved.CheckFt() returns expected values
"                Saved.GetFt() returns expected values
"                Filetype.Save() resets ft.opt_data and ft.global_data
"                Filetype.Save() adds (or overwrites) Saved.ft_dict.ft

set filetype=t
silent echo Getopt#Filetype

call vimtap#Plan(16)

" Getopt#Saved {{{1
" Getopt#Saved.SetFt() (x6) {{{2
let test_ft = Getopt#Filetype.New()

let Getopt#Saved.ft_dict.foo = { 'a':1 }

" .SetFt passes Filetype objects
call vimtap_except#Lives( "call g:Getopt#Saved.SetFt( 'foo', g:test_ft )",
         \ "Saved.SetFt() passes Filetype objects" )
" .SetFt clobbers pre-existing filetypes
call vimtap#Isnt( Getopt#Saved.ft_dict.foo, { 'a':1 }, 
         \ "Saved.SetFt() clobbers contained objects" )

" .SetFt fails non-hashes (x2)
call vimtap_except#Like( "call g:Getopt#Saved.SetFt( 'foo', [] )", 
         \ "^Getopt#Saved: ",
         \ "Saved.SetFt() fails non-Filetype objects: list" )
call vimtap_except#Like( "call g:Getopt#Saved.SetFt( 'foo', 'foo' )", 
         \ "^Getopt#Saved: ",
         \ "Saved.SetFt() fails non-Filetype objects: string" )

".SetFt fails non-Filetype objects(x2)
call vimtap_except#Like( "call g:Getopt#Saved.SetFt( 'foo', {} )",
         \ "^Getopt#Saved: ",
         \ "Saved.SetFt() fails non-Filetype objects: empty hash" )
call remove( test_ft, "HasData" )
call vimtap_except#Like( "call g:Getopt#Saved.SetFt( 'foo', g:test_ft )", 
         \ "^Getopt#Saved: ",
         \ "Saved.SetFt() fails non-Filetype objects: almost-correct object" )

" Getopt#Saved.CheckFt() (x3) {{{2
let Getopt#Saved.ft_dict.foo = Getopt#Filetype.New()

call vimtap_except#Lives( "call g:Getopt#Saved.CheckFt( 'foo' )",
         \ "Saved.CheckFt() runs" )
call vimtap#Is( Getopt#Saved.CheckFt( 'foo' ), 1,
         \ "Saved.CheckFt() succeeds (true result)" )
call vimtap#Is( Getopt#Saved.CheckFt( 'bar' ), 0,
         \ "Saved.CheckFt() succeeds (false result)" )

" Getopt#Saved.GetFt() (x3) {{{2
let test_ft = Getopt#Filetype.New()
let test_ft['test_val'] = 'bar'
let Getopt#Saved.ft_dict.foo = test_ft

call vimtap_except#Lives( "call g:Getopt#Saved.GetFt( 'foo' )",
         \ "Saved.GetFt() runs" )
call vimtap#Is( Getopt#Saved.GetFt( 'foo' ), test_ft,
         \ "Saved.GetFt() succeeds (true result)" )
call vimtap#Is( Getopt#Saved.GetFt( 'bar' ), 0,
         \ "Saved.GetFt() fails (false result)" )
" Getopt#Filetype {{{1
" Getopt#Filetype.Save() (x4) {{{2

let Getopt#Saved.ft_dict.t = {}
let test_ft = Getopt#Filetype.New()
let test_ft.opt_data = [ 1, 2 ]
let test_ft.global_data = { 'a':1 }

" .Save runs
call vimtap_except#Lives( "call g:test_ft.Save()", "Filetype.Save() runs" )

" .Save clobbers
call vimtap#Is( Getopt#Saved.ft_dict.t.last_data, [ 1, 2 ],
         \ "Filetype.Save() clobbers value in Getopt#Saved.ft_dict" )
" .Save clears opt_data, global_data
call vimtap#Is( test_ft.opt_data, [], "Filetype.Save() clears .opt_data" )
call vimtap#Is( test_ft.global_data, {}, "Filetype.Save() clears .global_data" )

