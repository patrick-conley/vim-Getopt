" Patrick Conley <pconley@uvic.ca>
" Last modified: 2012 Mar 20
"
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 13
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       A set of autoload/Getopt functions for unit testing.

function Getopt#minimal#init()
   echo "Initialized Getopt for minimal with g:Getopt_test_use_global = "
   echon g:Getopt_test_use_global
endfunc

function! Getopt.declare() dict
   let self.opt_data = [ { 'name': 'local_nodef1' },
                       \ { 'name': 'local_nodef2' },
                       \ { 'name': 'local_def', 'default': 0 } ]

   if ( ! empty( g:Getopt_test_use_global ) )
      let self.global_data = [ { 'name': 'global_nodef1' },
                             \ { 'name': 'global_nodef2' },
                             \ { 'name': 'global_def', 'default': 1 } ]
   endif
endfunc

function! Getopt.validate(D) dict
   if empty( a:D.local_nodef2 )
      return 0
   else if ( a:D.local_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function! Getopt.validate_global(D) dict
   if empty( a:D.global_nodef2 )
      return 0
   else if ( a:D.global_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function Getopt.write() dict
   let output = ''

   if ( ! empty( g:Getopt_test_use_global ) )
      if empty( self.global_opts['global_nodef1'] )
         let output .= "global_nodef1: UNSET\n"
      else
         let output .= "global_nodef1: " . self.global_opts['global_nodef1'] . "\n"
      endif

      let output .= "global_nodef2: " . self.global_opts['global_nodef2'] . "\n"
      let output .= "global_def: " . self.global_opts['global_def'] . "\n"
   else
      let output .= "NO GLOBALS\n"
   endif

   if ! empty( self.opts )
      for thisopt in self.opts

         if empty( thisopt['local_nodef1'] )
            let output .= "local_nodef1: UNSET\n"
         else
            let output .= "local_nodef1: " . thisopt['local_nodef1'] . "\n"
         endif

         let output .= "local_nodef2: " . thisopt['local_nodef2'] . "\n"
         let output .= "local_def: " . thisopt['local_def'] . "\n"
      end for
   else
      let output .= "NO LOCALS\n"
   endif

   return output

endfunc
