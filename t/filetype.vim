" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 26
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       Test cases to ensure filetypes are dealt with properly
"
" main() aborts on null filetype
" main() aborts on unrecognized filetype
" main() autoloads functions on unmatched last_ft
" main() does not autoload functions on matched last_ft
" main() autoloads functions on recognized filetype
call vimtap#Plan(6)

let &runtimepath .= "," . getcwd() . "/t"

silent edit foo.t_nofiletype
let g:Getopt_save_last = 0

" main() aborts on null filetype {{{1
try 
   let stat = Getopt.main()

   call vimtap#Like( stat, "Nothing to do", "main() aborts on null filetype" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" at " . v:throwpoint 
            \ . " on null filetype" )
endtry " }}}1

set filetype=t_nofiletype
" main() aborts on unrecognized filetype {{{1
try 
   let stat = Getopt.main()

   call vimtap#Like( stat, "No autoload/[^ ]* exists",
            \ "main() aborts on unmatched filetype" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" at " . v:throwpoint 
            \ . " on unmatched filetype" )
endtry " }}}1

" main() autoloads functions on unmatched last_ft {{{1
let Getopt.last_ft = 't_unmatched_last_ft'
try
   let stat = Getopt.main()

   call vimtap#Like( stat, "No autoload/[^ ]* exists",
            \ "main() aborts on unmatched last_ft" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" at " . v:throwpoint 
            \ . " on unmatched last_ft" )
endtry " }}}1

set filetype=t_filetype
" main() autoloads functions on recognized filetype {{{1
let Getopt.last_ft = 't_unmatched_last_ft'
try
   let stat = Getopt.main()

   call vimtap#Fail( "Getopt should have thrown error. Returned " . stat )
catch
   call vimtap#Like( v:exception, "Called Getopt#t_filetype#init successfully",
            \ "main() will autoload ft functions on matched last_ft" )
endtry " }}}1

let g:Getopt_save_last = 1
" main() autoloads functions on recognized filetype if g:Getopt_save_last {{{1
let Getopt.last_ft = 't_unmatched_last_ft'
try
   let stat = Getopt.main()

   call vimtap#Fail( "Getopt should have thrown error. Returned " . stat )
catch
   call vimtap#Like( v:exception, "Called Getopt#t_filetype#init successfully",
            \ "main() will autoload ft functions on matched last_ft" )
endtry " }}}1

" main() does not autoload functions on matched last_ft {{{1
let Getopt.last_ft = 't_filetype'
try
   let stat = Getopt.main()

   call vimtap#Fail( "main() should have thrown E716. Returned " . stat )
catch
   call vimtap#Like( v:exception, 'E716',
            \ "main() does not autoload ft functions on matched last_ft" )
endtry " }}}1

