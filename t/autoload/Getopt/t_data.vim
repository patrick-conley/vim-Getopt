" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 26
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       A set of autoload/Getopt functions for unit testing.
"                The variable g:Getopt_test_mods should have its bits set as
"                follows:
"                1: use local option data
"                2: use global option data
"                4: use a list for output
"                Make sure Getopt#t_data#init() is called if this is changed!

function Getopt#t_data#init() " {{{1
   if ! exists( "g:Getopt_test_mods" )
      let g:Getopt_test_mods = 0
   endif

   " Bitshift by hand
   let s:Getopt_test_use_local = fmod( g:Getopt_test_mods, 1*2 ) - 1 >= 0 ? 1 : 0
   let s:Getopt_test_use_global = fmod( g:Getopt_test_mods, 2*2 ) - 2 >= 0 ? 1 : 0
   let s:Getopt_test_use_list = fmod( g:Getopt_test_mods, 4*2 ) - 4 >= 0 ? 1 : 0
endfunc

function! Getopt.declare() dict " {{{1
   if ( ! empty( s:Getopt_test_use_local ) )
      let self.opt_data = [ { 'name': 'local_nodef1' },
                          \ { 'name': 'local_nodef2' },
                          \ { 'name': 'local_def', 'default': 0 } ]
   else
      let self.opt_data = ''
   endif

   if ( ! empty( s:Getopt_test_use_global ) )
      let self.global_data = [ { 'name': 'global_nodef1' },
                             \ { 'name': 'global_nodef2' },
                             \ { 'name': 'global_def', 'default': 1 } ]
   else
      let self.global_data = ''
   endif
endfunc

function! Getopt.validate(D) dict " {{{1
   if empty( a:D.local_nodef2 )
      return 0
   elseif ( a:D.local_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function! Getopt.validate_global(D) dict " {{{1
   if empty( a:D.global_nodef2 )
      return 0
   elseif ( a:D.global_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function Getopt.write() dict " {{{1
   if exists( "output" )
      unlet output
   endif

   " Output a string if s:Getopt_test_use_list is unset
   if empty( s:Getopt_test_use_list )
      let output = ''

      " Globals (if set)
      if ( ! empty( s:Getopt_test_use_global ) )
         if empty( self.global_opts['global_nodef1'] )
            let output .= "global_nodef1: UNSET\n"
         else
            let output .= "global_nodef1: " 
                     \ . self.global_opts['global_nodef1'] . "\n"
         endif

         let output .= "global_nodef2: " 
                  \ . self.global_opts['global_nodef2'] . "\n"
         let output .= "global_def: " . self.global_opts['global_def'] . "\n"
      else
         let output .= "NO GLOBALS\n"
      endif

      " All locals (if any exist)
      if ! empty( self.opts )
         for thisopt in self.opts

            if empty( thisopt['local_nodef1'] )
               let output .= "local_nodef1: UNSET\n"
            else
               let output .= "local_nodef1: " . thisopt['local_nodef1'] . "\n"
            endif

            let output .= "local_nodef2: " . thisopt['local_nodef2'] . "\n"
            let output .= "local_def: " . thisopt['local_def'] . "\n"
         endfor
      else
         let output .= "NO LOCALS\n"
      endif

   " Output a list if s:Getopt_test_use_list is set
   else
      let output = []

      " Globals (if set)
      if ! empty( s:Getopt_test_use_global )
         if empty( self.global_opts['global_nodef1'] )
            let output += [ "global_nodef1: UNSET" ]
         else
            let output += [ "global_nodef1: "
                     \ . self.global_opts['global_nodef1'] ]
         endif

         let output += [ "global_nodef2: "
                  \ . self.global_opts['global_nodef2'] ]
         let output += [ "global_def: " . self.global_opts['global_def'] ]
      else
         let output += [ "NO GLOBALS" ]
      endif

      " All locals
      if ! empty( self.opts )
         for thisopt in self.opts

            if empty( thisopt['local_nodef1'] )
               let output += [ "local_nodef1: UNSET" ]
            else
               let output += [ "local_nodef1: " . thisopt['local_nodef1'] ]
            endif

            let output += [ "local_nodef2: " . thisopt['local_nodef2'] ]
            let output += [ "local_def: " . thisopt['local_def'] ]
         endfor
      else
         let output += [ "NO LOCALS" ]
      endif

   endif

   return output

endfunc
