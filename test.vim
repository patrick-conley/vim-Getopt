source ~/.vim/plugin/Getopt.vim
set lazyredraw
let s:results = []

" Testing functions {{{1
let s:n_tests = 0
function Match( output, matchstr, name )
   let s:n_tests = s:n_tests + 1
   let result = ( a:output =~ a:matchstr ) ? 'ok' : 'not ok'
   let s:results += [ printf( '%2d %s - %s', s:n_tests, result, a:name ) ]
endfunc

" }}}1

" Empty file {{{1
silent edit foo

redir => status | silent call Getopt.main() | redir END

call Match( status, "Nothing to do", "main() aborts on null filetype" )

" File with no Getopt {{{1
silent edit foo.html

try 

   let name = "main() aborts on unmatched filetype"
   redir => status | silent call Getopt.main() | redir END
   call Match( status, "No autoload/[^ ]* exists", name )

   let name = "input() aborts clearly on unmatched filetype"
   try
      silent call Getopt.input()
   catch
      let status = v:exception
   endtry
   call Match( status, "No option information is defined", name )

catch
   let s:n_tests = s:n_tests + 1
   let s:results += 
            \[ printf( '%2d %s - %s', s:n_tests, 'not ok: exception', name ) ]
endtry

" }}}1

" display results
edit test-results
setlocal buftype=nofile
setlocal noswapfile

call append( '0', s:results )

if match( s:results, "^[0-9]* not" ) == -1
   call append( '$', printf( "All %d tests passed", s:n_tests ) )
endif
