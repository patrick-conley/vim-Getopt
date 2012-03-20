" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Mar 19
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
" optstr     : Final option string
" last_global: Hash of valid global data from last run
" last_opts  : List of valid option hashes from last run
" last_ft    : Filetype of the last file Getopted
let Getopt = {  'global_data': [], 'opt_data': [], 'global_opts': {},
         \ 'opts': [], 'optstr': '', 'last_global': {}, 'last_opts': [],
         \ 'last_ft': ''
         \ }

" Define the command
if !exists( ":Getopt" )
   command -nargs=0 Getopt call Getopt.main()
endif

" Function:  main {{{1
" Arguments: N/A
" Purpose:   Parse input; call language-specific functions
function! Getopt.main() dict

   try

      " Initialize this filetype's version of the Getopt functions
      if ( empty( &ft ) || &ft != self.last_ft )
         call eval( "Getopt#" .&ft . "#init()" )
      endif

      " Define the list of valid options
      call self.declare()
      if empty( "self.opt_data" )
         throw "opt_data not set by Getopt.declare()"
      endif

      " Get input from user
      call self.input()

      if empty( self.opts ) || 
               \ ( empty( self.global_opts ) && ! empty( self.global_data ) )
         throw "No options entered. Nothing to do."
      endif

      " Set the string to be printed
      call self.write()

      if empty( "self.optstr" )
         throw "optstr not set by Getopt.write()"
      else
         call append( ".", self.optstr )
         let self.optstr = ''
      endif

   catch E117
      echomsg "No autoload/Getopt/" . &ft . ".vim exists. Nothing to do."

   catch "^[a-z_]* not set by"
      echohl Error | echo v:exception | echohl None

   catch "^Invalid"
      echohl Error | echo v:exception | echohl None

   catch "Nothing to do"
      echo v:exception

   endtry

endfunc

" Function:  Getopt.input() {{{1
" Arguments: N/A (valid options from self)
" Purpose:   Ask for user to input each option, then validate it
function Getopt.input() dict

   try

      " Enter global option settings {{{2
      if ! empty( self.global_data )

         let global_input = {}

         echo "Single-use data:"

         for this in self.global_data
            if exists( "this.default" )
               let global_input[this.name] 
                        \ = input( self.rename_for_input( this.name ) . ' > ',
                        \ this.default )
            else
               let global_input[this.name] 
                        \ = input( self.rename_for_input( this.name ) . ' > ' )
            endif
         endfor

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
      while ( 1 )

         echo "Press ^C to finish"

         let opt_input = ''

         for this in self.opt_data
            if exists( "this.default" )
               let opt_input[this.name] 
                        \ = input( self.rename_for_input( this.name ) . ' > ',
                        \ this.default )
            else
               let opt_input[this.name]
                        \ = input( self.rename_for_input( this.name ) . ' > ' )
            endif

            if self.validate( opt_input )
               let self.opts += [ opt_input ]
            else
               echomsg "Invalid option data ignored"
               continue
            endif
         endfor

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

   let var = substitute( a:var, '_', ' ', '' )
   let var = substitute( a:var, '^\(is\|has\).*$', '&?', '' )

   return a:var
endfunc

" }}}1

" END }}}

let &cpo = s:save_cpo
