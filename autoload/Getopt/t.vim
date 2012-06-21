" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 21
" License:       This module (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt
" Summary:       A set of autoload/Getopt/ft functions for unit testing.
"
"                This FT module takes three option keys (both in global and
"                local functions): the second must not be empty, the third
"                must not equal 2.
"
"                A few flags control the module's behaviour. They can be set
"                persistently by prefixing the flag's name with 'g:', or for a
"                single call to .New() by passing them as parameters to
"                Getopt#t#ft.New() or Getopt#Filetype.New(). If flags passed
"                as arguments are set to a number less than 0, their default
"                will be used.
"
"                Getopt_var_flags - controls which variables are defined:
"                1: defines opt_keys
"                2: defines global_keys
"                4: defines input
"                default: 5
"
"                Getopt_func_flags - controls which functions are defined:
"                1: Validate()
"                2: Validate_global()
"                4: Write()
"                default: 5
"
"                Getopt_func_opt_flag - controls various things. If a
"                function is not defined, the corresponding bit is ignored.
"                1: New() requires no inputs
"                2: Validate_global() requires a single input
"                4: Validate() requires a single input
"                8: Write() requires no arguments
"                default: 15
"
"                Lastly, Getopt_write_output sets whether Write() outputs a
"                1: string
"                2: list
"                3: hash
"                4: nothing
"                default: 1
"                This is an integer variable, not a flag!


let Getopt#t#ft = {}

function Getopt#t#ft.New(...) dict " {{{1

   " Declare flags {{{2
   let s:Getopt_var_flags = a:0 == 4 && a:1 >= 0 ? a:1 
            \ : exists("g:Getopt_var_flags") ? g:Getopt_var_flags : 5
   let s:Getopt_func_flags = a:0 == 4 && a:1 >= 0 ? a:1 
            \ : exists("g:Getopt_func_flags") ? g:Getopt_func_flags : 5
   let s:Getopt_func_opt_flag = a:0 == 4 && a:1 >= 0 ? a:1 
            \ : exists("g:Getopt_func_opt_flag") ? g:Getopt_func_opt_flag : 5
   let s:Getopt_write_output = a:0 == 4 && a:1 >= 0 ? a:1 
            \ : exists("g:Getopt_write_output") ? g:Getopt_write_output : 5
   " }}}2


   " Check arguments
   if ( ( a:0 != 0 && a:0 != 4 ) && and( s:Getopt_func_opt_flag, 1 ) )
      throw 'Getopt(E118): Too many arguments to function New'
   endif

   let harness = copy( self )

   " Declare variables (controlled by s:Getopt_var_flags) {{{2

   " opt_keys
   if and( s:Getopt_var_flags, 1 )
      let harness.opt_keys = [ { 'name': 'local_nodef1' },
                          \ { 'name': 'local_nodef2' },
                          \ { 'name': 'local_def', 'default': 0 } ]
   endif

   " global_keys
   if and( s:Getopt_var_flags, 2 )
      let harness.global_keys = [ { 'name': 'global_nodef1' },
                             \ { 'name': 'global_nodef2' },
                             \ { 'name': 'global_def', 'default': 1 } ]
   endif

   " input
   if and( s:Getopt_var_flags, 4 )
      let harness.input = []

      if and( s:Getopt_var_flags, 2 )
         let harness.input += [ 1, 1, 1 ]
      endif

      if and( s:Getopt_var_flags, 1 )
         let harness.input += [ 1, 1, 1 ]
      endif
   endif


   " Declare functions (controlled by s:Getopt_func_flags) {{{2
   if ! and( s:Getopt_func_flags, 1 )
      unlet harness.Validate
   endif
   if ! and( s:Getopt_func_flags, 2 )
      unlet harness.Validate_global
   endif
   if ! and( s:Getopt_func_flags, 4 )
      unlet harness.Write
   endif

   " }}}2

   return harness

endfunc

function! Getopt#t#ft.Validate(...) dict " {{{1

   " Check arguments
   if ( a:0 < 1 && and( s:Getopt_func_opt_flag, 4 ) )
      throw 'Getopt(E119): Not enough arguments to function Validate'
   endif
   if ( a:0 > 1 && and( s:Getopt_func_opt_flag, 4 ) )
      throw 'Getopt(E118): Too many arguments to function Validate'
   endif
  
   if empty( a:1.local_nodef2 )
      return 0
   elseif ( a:1.local_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function! Getopt#t#ft.Validate_global(...) dict " {{{1

   " Check arguments
   if ( a:0 < 1 && and( s:Getopt_func_opt_flag, 2 ) )
      throw 'Getopt(E119): Not enough arguments to function Validate_global'
   endif
   if ( a:0 > 1 && and( s:Getopt_func_opt_flag, 2 ) )
      throw 'Getopt(E118): Too many arguments to function Validate_global'
   endif
  
   if empty( a:1.global_nodef2 )
      return 0
   elseif ( a:1.global_def == 2 )
      return 0
   else
      return 1
   endif
endfunc

function Getopt#t#ft.Write() dict " {{{1

   " Check arguments
   if ( a:0 > 0 && and( s:Getopt_func_opt_flag, 8 ) )
      throw 'Getopt(E118): Too many arguments to function Write'
   endif
  
   " Clear the result variable so it can be set as a string or list
   if exists( "output" )
      unlet output
   endif

   " Output a list if the flag is set, a string else
   if ( s:Getopt_write_output == 1 )
      " {{{
      let output = []

      " Globals (if set)
      if and( s:Getopt_var_flags, 2 )
         if empty( self.global_data['global_nodef1'] )
            let output += [ "global_nodef1: UNSET" ]
         else
            let output += [ "global_nodef1: "
                     \ . self.global_data['global_nodef1'] ]
         endif

         let output += [ "global_nodef2: "
                  \ . self.global_data['global_nodef2'] ]
         let output += [ "global_def: " . self.global_data['global_def'] ]
      else
         let output += [ "NO GLOBALS" ]
      endif

      " All locals
      if ! empty( self.opt_data )
         for opt_data_item in self.opt_data

            if empty( opt_data_item['local_nodef1'] )
               let output += [ "local_nodef1: UNSET" ]
            else
               let output += [ "local_nodef1: " . opt_data_item['local_nodef1'] ]
            endif

            let output += [ "local_nodef2: " . opt_data_item['local_nodef2'] ]
            let output += [ "local_def: " . opt_data_item['local_def'] ]
         endfor
      else
         let output += [ "NO LOCALS" ]
      endif

      " }}}
   elseif ( s:Getopt_write_output == 2 )
      " {{{
      let output = ''

      " Globals (if set)
      if and( s:Getopt_var_flags, 2 )
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

   " }}}
   elseif ( s:Getopt_write_output == 3 )
      output = {}
   elseif ( s:Getopt_write_output == 4 )
      return
   endif

   return output

endfunc
