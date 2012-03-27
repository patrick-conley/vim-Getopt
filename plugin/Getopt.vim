" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 26
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt

if exists( "g:loaded_Getopt" ) || &cp
   finish
endif
let loaded_Getopt = 1

let s:save_cpo = &cpo " Save and reset line continuation opts to default
set cpo&vim

" global_data: List of data needed once
" opt_data   : List of data to generate each opt string
" global_opts: Hash of validated global data
" opts       : List of validated option hashes
" optstr     : Final option string (let uninitialized because it may be a list
"              or string)
" last_global: Hash of valid global data from last run
" last_opts  : List of valid option hashes from last run
" last_ft    : Filetype of the last file Getopted
" input      : For testing use only. If input exists and is a list, its data
"              will be used in get_input() in place of user requests
let Getopt = {  'global_data': [], 'opt_data': [], 'global_opts': {},
         \ 'opts': [], 'last_global': {}, 'last_opts': [], 'last_ft': ''
         \ }

" Define the command
if !exists( ":Getopt" )
   command -nargs=0 Getopt echo Getopt.main()
endif

if !exists( "g:Getopt_save_last" )
   let g:Getopt_save_last = 1
endif

" Function:  main {{{1
" Arguments: N/A
" Purpose:   Parse input; call language-specific functions
function! Getopt.main() dict

   try

      " Initialize this filetype's version of the Getopt functions
      if ! ( g:Getopt_save_last && &ft == self.last_ft )
         call eval( "Getopt#" .&ft . "#init()" )
         let self.last_ft = &ft
      endif

      " Define the list of valid options
      call self.declare()
      if empty( self.opt_data )
         throw "opt_data not set by Getopt.declare()"
      endif

      " Get input from user
      call self.get_input()

      if empty( self.opts ) || 
               \ ( empty( self.global_opts ) && ! empty( self.global_data ) )
         throw "No options entered. Nothing to do."
      endif

      " Set the string to be printed
      let self.optstr = self.write()

      if empty( self.optstr )
         throw "optstr not set by Getopt.write()"
      elseif ( exists( "self.input" ) )
         return self.optstr
      else
         call append( ".", self.optstr )
         unlet self.optstr
      endif

      " Remove used data
      let self.global_opts = {}
      let self.opts = []

   catch E117
      return "No autoload/Getopt/" . &ft . ".vim exists. Nothing to do."

   catch /Nothing to do/
      return v:exception

   catch /^[a-z_]* not set by/
      echohl Error | echo v:exception | echohl None

   catch /^Invalid/
      echohl Error | echo v:exception | echohl None

   catch E684
      echohl Error | echo "Getopt.input is probably defined incorrectly:"
      echohl None
      return v:exception

   endtry

endfunc

" Function:  Getopt.get_input() {{{1
" Arguments: N/A
" Purpose:   Ask for user to input each global and local option, then validate
"            it
"            If the input list of options is given, no input is requested.
function Getopt.get_input() dict

   " Make sure there aren't leftovers from the last run!
   let self.opts = []
   let self.global_opts = {}

   " Data may be entered into 
   if ( exists( "self.input" ) && ! empty( self.input )
            \ &&  type( self.input ) != type([]) )
      throw "Invalid argument to Getopt.get_input()"
   endif

   try
      " Enter global option settings {{{2
      if ! empty( self.global_data )

         let global_input = {}

         echo "Single-use data:"

         for this in self.global_data
            let global_input[this.name] = ''

            " Read stored input
            if exists( "self.input" )
               let global_input[this.name] = remove( self.input, 0 )

            " Read input from stdin, possibly with a default arg
            elseif exists( "this.default" )
               let global_input[this.name] 
                        \ = input( self.rename_for_input(this.name) . ' > ',
                        \ this.default )
            else
               let global_input[this.name] 
                        \ = input( self.rename_for_input(this.name) . ' > ' )
            endif
         endfor

         " Validate input
         if self.validate_global( global_input )
            let self.global_opts = global_input
         else
            throw "Invalid global data entered"
         endif

      endif

      " Enter settings for each option {{{2

      if empty( self.opt_data )
         throw "No option information is defined. Nothing to do"
      endif

      echo "Per-option data"
      echo "Press ^C to finish"
      while ( 1 )

         if empty( self.input )
            break
         endif

         let opt_input = {}
         for this in self.opt_data
            let opt_input[this.name] = ''

            " Read stored input
            if exists( "self.input" )
               let opt_input[this.name] = remove( self.input, 0 )

            " Read input from stdin, possibly with a default arg
            elseif exists( "this.default" )
               let opt_input[this.name] 
                        \ = input( self.rename_for_input(this.name) . ' > ',
                        \ this.default )
            else
               let opt_input[this.name]
                        \ = input( self.rename_for_input(this.name) . ' > ' )
            endif

         endfor

         " Validate input
         if self.validate( opt_input )
            let self.opts += [ opt_input ]
            echo "Option data recorded"
         else
            echomsg "Invalid option data ignored"
         endif

      endwhile 

      " }}}2

   catch /^Vim:Interrupt/
      " Valid end of input
   endtry
      
endfunc

" Function:  Getopt.rename_for_input() {{{1
" Arguments: A single option name
" Purpose:   Make some simple substitutions to variable names before display
"            in input prompts
function! Getopt.rename_for_input( var )
   let var = a:var

   let var = substitute( var, '_', ' ', '' )
   let var = substitute( var, '^\(is\|has\|does\).*$', '&?', '' )

   return var
endfunc

" }}}1

" END }}}

let &cpo = s:save_cpo
