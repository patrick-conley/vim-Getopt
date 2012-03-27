" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 26
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       Test cases to check the script runs beginning-to-end
"
" works with no globals (x3)
" works with globals
" works with list output (x3)
call vimtap#Plan(7)

let &runtimepath .= "," . getcwd() . "/t"

silent edit foo.t_full
set filetype=t_data

let g:Getopt_test_mods = 1
" works with no globals (x3) {{{1

let Getopt.last_ft = ''
" single opt {{{2
let Getopt.input = [ '', 1, 1 ]
let result = "NO GLOBALS\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 1\n" . "local_def: 1\n"

try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with a single local opt" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry

" several opts {{{2
let Getopt.input = [ 'a', 'b', 0, 1, 2, 'c', '', 3, '' ]
let result = "NO GLOBALS\n"
         \ . "local_nodef1: a\n" . "local_nodef2: b\n" . "local_def: 0\n"
         \ . "local_nodef1: 1\n" . "local_nodef2: 2\n" . "local_def: c\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 3\n" . "local_def: \n"

try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with several local opts" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry

" several opts with failures {{{2
let Getopt.input = [ '', '', '',  '', 1, 1,  '', 2, 2,  '', 3, 3,  '', '', 2 ]
let result = "NO GLOBALS\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 1\n" . "local_def: 1\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 3\n" . "local_def: 3\n"

let Getopt.last_ft = ''
try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with failing local opts" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1

let g:Getopt_test_mods = 3
" works with globals {{{1
let Getopt.input = [ '', 1, 1,  '', 1, 1 ]
let result = "global_nodef1: UNSET\n" . "global_nodef2: 1\n" . "global_def: 1\n"
         \ . "local_nodef1: UNSET\n" . "local_nodef2: 1\n" . "local_def: 1\n"

let Getopt.last_ft = ''
try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with global opts" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry

endtry " }}}1

let g:Getopt_test_mods = 5
" works with list output (x3) {{{1
unlet result
unlet output

let Getopt.last_ft = ''
" single opt {{{2
let Getopt.input = [ '', 1, 1 ]
let result = [ "NO GLOBALS",
             \ "local_nodef1: UNSET", "local_nodef2: 1", "local_def: 1" ]

try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with a single local opt" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry

" several opts {{{2
let Getopt.input = [ 'a', 'b', 0, 1, 2, 'c', '', 3, '' ]
let result = [ "NO GLOBALS",
             \ "local_nodef1: a", "local_nodef2: b", "local_def: 0",
             \ "local_nodef1: 1", "local_nodef2: 2", "local_def: c",
             \ "local_nodef1: UNSET", "local_nodef2: 3", "local_def: " ]

try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with several local opts" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry

" several opts with failures {{{2
let Getopt.input = [ '', '', '',  '', 1, 1,  '', 2, 2,  '', 3, 3,  '', '', 2 ]
let result = [ "NO GLOBALS",
             \ "local_nodef1: UNSET", "local_nodef2: 1", "local_def: 1",
             \ "local_nodef1: UNSET", "local_nodef2: 3", "local_def: 3" ]

let Getopt.last_ft = ''
try
   let output = Getopt.main()

   call vimtap#Is( output, result, "Getopt works with failing local opts" )
catch
   call vimtap#Fail( "Getopt threw \"" . v:exception . "\" at "
            \ . v:throwpoint . " when valid data entered" )
endtry " }}}1
