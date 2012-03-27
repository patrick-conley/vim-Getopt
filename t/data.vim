" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 26
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       Test cases to ensure data is dealt with properly

" main() aborts if no opt data is defined
" get_input() throws if no opt data is defined
" main() aborts if no data is entered
" get_input() passes valid local data (x2)
" get_input() ignores invalid local data (x3)
" get_input() passes valid global data
" get_input() throws invalid global data (x2)
" write() writes data if entered
" write() writes list data if entered
" write() writes proper data if none entered (x2)
call vimtap#Plan(15)

let &runtimepath .= "," . getcwd() . "/t"

silent edit foo.t_data
set filetype=t_data
let g:Getopt_save_last = 0

" main() aborts if no opt data is defined {{{1
try
   redir => stat
   echo Getopt.main()
   redir END

   call vimtap#Like( stat, "opt_data not set by Getopt.declare()",
            \ "main() aborts if opt_data undefined" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " on no opt_data" )
endtry " }}}1

" get_input() throws if no opt data is defined {{{1
try
   let stat = Getopt.get_input()

   call vimtap#Fail( "get_input() should have thrown error. Returned " . stat )
catch
   call vimtap#Like( v:exception, "No option information is defined",
            \ "get_input() requires declared option information" )
endtry " }}}1

let g:Getopt_test_mods = 1
call Getopt#t_data#init()
" main() aborts if no data is entered {{{1
let Getopt.input = []

try
   let stat = Getopt.main()

   call vimtap#Like( stat, "No options entered. Nothing to do",
            \ "main() aborts if no data entered" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when no data entered" )
endtry " }}}1

" get_input() passes valid local data (x2) {{{1
" {{{2
let Getopt.input = [ 'a', 'b', 4 ]
let result = [ { 'local_nodef1': 'a', 'local_nodef2': 'b', 'local_def':4 } ]

try
   call Getopt.get_input()

   call vimtap#Is( Getopt.opts, result, "get_input() passes valid data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry

" {{{2
let Getopt.input = [ 'a', 'b', 0, 1, 2, 'c', '', 3, '' ]
let result = [ { 'local_nodef1': 'a', 'local_nodef2': 'b', 'local_def': 0 },
             \ { 'local_nodef1': 1, 'local_nodef2': 2, 'local_def': 'c' },
             \ { 'local_nodef1': '', 'local_nodef2': 3, 'local_def': '' } ]

try
   call Getopt.get_input()

   call vimtap#Is( Getopt.opts, result, "get_input() passes vaild data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1

" get_input() ignores invalid local data (x3) {{{1
" {{{2
let Getopt.input = [ '', '', '' ]
let result = []

try
   call Getopt.get_input()

   call vimtap#Is( Getopt.opts, result, "get_input() ignores invalid data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when invalid data entered" )
endtry

" {{{2
let Getopt.input = [ '', 2, 2 ]
let result = []

try
   call Getopt.get_input()

   call vimtap#Is( Getopt.opts, result, "get_input() ignores invalid data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when invalid data entered" )
endtry

" {{{2
" Fail first, pass, fail second, pass, fail both
let Getopt.input = [ '', '', '',  '', 1, 1,  '', 2, 2,  '', 3, 3,  '', '', 2 ]
let result = [ { 'local_nodef1': '', 'local_nodef2': 1, 'local_def': 1 },
             \ { 'local_nodef1': '', 'local_nodef2': 3, 'local_def': 3 } ]

try
   call Getopt.get_input()

   call vimtap#Is( Getopt.opts, result, "get_input() ignores invalid data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when invalid data entered" )
endtry " }}}1

let g:Getopt_test_mods = 3
call Getopt#t_data#init()
" get_input() passes valid global data {{{1
let Getopt.input = [ '', 1, 1,  '', 1, 1 ]

unlet result
let result = { 'global_nodef1': '', 'global_nodef2': 1, 'global_def': 1 }

try
   call Getopt.declare()
   call Getopt.get_input()

   call vimtap#Is( Getopt.global_opts, result, 
            \ "get_input() passes valid global data" )
catch
   call vimtap#Fail( "get_input() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1

" get_input() throws invalid global data (x2) {{{1
" {{{2
let Getopt.input = [ '', '', 1 ]

try
   call Getopt.get_input()

   call vimtap#Fail( "get_input() should have thrown error" )
catch
   call vimtap#Like( v:exception, "Invalid global data entered", 
            \ "get_input() throws invalid global data" )
endtry

" {{{2
let Getopt.input = [ '', 1, 2 ]

try
   call Getopt.get_input()

   call vimtap#Fail( "get_input() should have thrown error" )
catch
   call vimtap#Like( v:exception, "Invalid global data entered", 
            \ "get_input() throws invalid global data" )
endtry " }}}1

" write() writes data if entered {{{1
let Getopt.global_opts = 
         \{ 'global_nodef1': '', 'global_nodef2':1, 'global_def':1 }
let Getopt.opts = [ { 'local_nodef1': '', 'local_nodef2': 1, 'local_def': 1 } ]

unlet result
let result = "global_nodef1: UNSET\n" . "global_nodef2: 1\n" . "global_def: 1\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 1\n" . "local_def: 1\n"

try
   let output = Getopt.write()

   call vimtap#Is( output, result, "write() prints output" )
catch
   call vimtap#Fail( "write() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry "}}}1

let g:Getopt_test_mods = 7
call Getopt#t_data#init()
" write() writes list data if entered {{{1
let Getopt.global_opts = 
         \{ 'global_nodef1': '', 'global_nodef2':1, 'global_def':1 }
let Getopt.opts = [ { 'local_nodef1': '', 'local_nodef2': 1, 'local_def': 1 } ]

unlet output
unlet result
let result = [ "global_nodef1: UNSET", "global_nodef2: 1", "global_def: 1",
         \ "local_nodef1: UNSET", "local_nodef2: 1", "local_def: 1" ]

try
   let output = Getopt.write()

   call vimtap#Is( output, result, "write() prints list output" )
catch
   call vimtap#Fail( "write() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry "}}}1

let g:Getopt_test_mods = 3
call Getopt#t_data#init()
" write() writes data if not entered {{{1
let Getopt.global_opts = 
         \{ 'global_nodef1': '', 'global_nodef2':1, 'global_def':1 }
let Getopt.opts = []

unlet output
unlet result
let result = "global_nodef1: UNSET\n" . "global_nodef2: 1\n" . "global_def: 1\n"
         \ . "NO LOCALS\n"

try
   let output = Getopt.write()

   call vimtap#Is( output, result, "write() prints output" )
catch
   call vimtap#Fail( "write() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1
let g:Getopt_test_mods = 1
call Getopt#t_data#init()
" {{{1
let Getopt.global_opts = {}
let Getopt.opts = []
let result = "NO GLOBALS\n" . "NO LOCALS\n"

try
   let output = Getopt.write()

   call vimtap#Is( output, result, "write() prints output" )
catch
   call vimtap#Fail( "write() threw \"" . v:exception . "\" at " 
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1
