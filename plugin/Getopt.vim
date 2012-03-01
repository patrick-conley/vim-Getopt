" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Feb 29
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt

if exists( "g:loaded_Getopt" ) || &cp
   finish
endif
let loaded_Getopt = 1

let s:save_cpo = &cpo " Save and reset line continuation opts to default
set cpo&vim

let Getopt = { 'ft':'', 'opts':'' }

" Note:
" :command -nargs=? MyCom exe "let Var = eval( string( [" . <q-args> . ]" ) )"
" creates a list of a dictionary set to the contents of
" :MyCom { 'a':1, 'b':2, ... }
" The [] wrapper is necessary so it works in case <args> is empty

" Get zero or one options from the command line
if !exists( ":Getopt" )
   command -nargs=? Getopt 
            \:call Getopt.parse_options( eval( "string( [ " . <q-args> . " ] )" ) )
endif

" Note On Data Format:
" The option strings are a list of dicts. Possible keys are
"
"        'name': (string) The option's full name
"       'short': (string) The option's short name
"     'has_arg': (bool)   Whether the option takes an argument:
"                         0 - no arg
"                         1 - required arg
"                         2 - optional arg
"     'def_arg': (any)    The option's default argument (FIXME: do I want this?)
"
" No single option is required. 'has_arg' will default to 0. One of 'name' and
" 'short' must exist.

" Function:  parse_options( {option?} ) {{{1
" Arguments: None or
"            A list of hashes (of each option) or
"            Several hashes (one for each option)
" Purpose:   Parse input; call a language-specific function
if !exists( "Getopt.parse_options" )
   function Getopt.parse_options( ... ) dict

      let self.ft = &ft
      let self.opts = ''

      let ft_function_name = "self." . self.ft

      if exists( ft_function_name )
         exe "call " . ft_function_name . "()"
      else
         call self.default()
      endif

   endfunc
endif

" }}}1

" Functions:  Getopt.<filetype>() {{{1
" Arguments:  N/A (option list comes from self.)
" Purpose:    Define the Getopt contents appropriate for a certain filetype.
"
" These functions should be defined in
" <runtimepath>/ftplugin/<filetype>_Getopt.vim
if !exists( "Getopt.default" )
   function Getopt.default() dict
      throw "No Getopt ftplugin exists for " . self.ft . " files"
   endfunc
endif

" }}}1

" END }}}

let &cpo = s:save_cpo
