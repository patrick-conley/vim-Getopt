set lazyredraw

call vimtap#Plan(3)

" Empty file {{{1
silent edit foo

try 
   redir => stat
   silent call Getopt.main()
   redir END

   call vimtap#Like( stat, "Nothing to do", "main() aborts on null filetype" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" on null filetype" )
endtry

" File with no Getopt {{{1
silent edit foo.html

try 
   redir => stat
   silent call Getopt.main()
   redir END

   call vimtap#Like( stat, "No autoload/[^ ]* exists",
            \ "main() aborts on unmatched filetype" )
catch
   call vimtap#Fail( "main() threw \"" . v:exception . "\" on unmatched filetype" )
endtry

try
   redir => stat
   silent call Getopt.input()
   redir END

   call vimtap#Fail( "input() returned with \"" . stat . '"' )
catch
   call vimtap#Like( v:exception, "No option information is defined",
            \ "input() requires declared option information" )
endtry

" }}}1

" display results
