" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Apr 27
" License:       This plugin (and all assoc. files) are available under the
"                same license as Vim itself.
" Documentation: see Getopt.txt and Getopt-internal.txt

" Save line continuation opts and reset to default
let s:save_cpo = &cpo
set cpo&vim

" CLASSES {{{1
" Getopt#Filetype {{{2
" Description: This class contains all the data used while creating option
" strings, as well as the various functions specific to a filetype and
" declared in the filetype's autoloaded plugin.

let Getopt#Filetype = {}

" .New {{{3
function Getopt#Filetype.New() dict
   let harness = copy( self )
   call self.Init( harness )

   " Add the filetype functions to the object
   call extend( harness, g:Getopt#{&ft}#ft.New() )

   " Double-check opt_keys is set
   if empty( harness.opt_keys )
      throw "Getopt#Filetype: opt_keys not set by Getopt#" . &ft . "#ft.New()"
   endif

   return harness
endfunc

" .Init {{{3
function Getopt#Filetype.Init( self ) dict
   let a:self.global_keys = []
   let a:self.opt_keys = []

   let a:self.global_data = {}
   let a:self.opt_data = []
   let a:self.last_global = {}
   let a:self.last_data = []
endfunc

" .Save {{{3
function Getopt#Filetype.Save() dict
   if ( ! empty( self.global_data ) || ! empty( self.opt_data ) )
      let self.last_global = self.global_data
      let self.global_data = {}

      let self.last_data = self.opt_data
      let self.opt_data = []

      call g:Getopt#Saved.SetFt( &ft, self )
   endif
endfunc

" .HasData {{{3
function Getopt#Filetype.HasData() dict
   if empty( self.opt_data )
      return 0
   elseif ! empty( self.global_keys ) && empty( self.global_data )
      return 0
   endif

   return 1
endfunc

" .SetInputList {{{3
function Getopt#Filetype.SetInputList( input ) dict

   " Validate the list
   if type( a:input ) != type( [] )
      throw "Getopt#Filetype: Non-interactive input must be a list"
   endif

   " Set the list
   let self.input = a:input
endfunc

" .Validate {{{3
" See autoload/Getopt/{ft}.vim


" .Validate_global {{{3
" See autoload/Getopt/{ft}.vim


" .Write {{{3
" See autoload/Getopt/{ft}.vim

" }}}3

" Getopt#Saved {{{2
" Description: A static class meant to store previously-run Getopt#Filetypes
" to allow the reuse of a filetype's data. Access is provided through a single
" get/set pair

let Getopt#Saved = {}

" .Init {{{3
" Note: although only one object of this class should exist, this method
" deliberately fails to check if the data has already been set, as I may need
" to reset the class to a blank state
function Getopt#Saved.Init() dict
   let self.filetypes = {}
endfunc

" .SetFt {{{3
function Getopt#Saved.SetFt( ft, obj ) dict
   let self.filetypes[a:ft] = a:obj
endfunc

" GetFt {{{3
function Getopt#Saved.GetFt( ft ) dict
   return self.filetypes[a:ft]
endfunc

" CheckFt {{{3
function Getopt#Saved.CheckFt( ft ) dict
   return exists( "Getopt.filetype." . a:ft )
endfunc
" }}}3

call g:Getopt#Saved.Init()

" }}}2
" }}}1

" FUNCTIONS {{{1
" Function:  Run {{{2
" Purpose:   Parse input, run the language-specific functions
" Arguments: Non-interactive input (for test cases)
" Return:    Error messages (as appropriate)
function Getopt#Run(...)

   try

      " Initialize a filetype object (if needed)
      if ( g:Getopt#Saved.CheckFt( &ft ) )
         let buffer_ft = g:Getopt#Saved.GetFt( &ft )
      else
         let buffer_ft = g:Getopt#Filetype.New()
      endif

      " Set the non-interactive input list if it exists (for unit tests only)
      if a:0 == 1
         call buffer_ft.SetInputList( a:1 )
      endif

      " Get input from user
      call Getopt#_Get_input( buffer_ft )

      if ! ( buffer_ft.HasData() )
         throw "Getopt: No options entered. Nothing to do."
      endif

      " Set and print the option string
      let optstr = buffer_ft.Write()

      if empty( optstr )
         throw "Getopt: optstr not set by .Write()"
      elseif ( exists( "buffer_ft.input" ) )
         return optstr
      else
         call append( ".", optstr )
         unlet optstr
      endif

      call buffer_ft.Save()

   " No ft autoload found
   catch E117
      return "No autoload/Getopt/" . &ft . ".vim exists. Nothing to do."

   " mild abort
   catch /Nothing to do/
      return v:exception

   " serious abort
   catch /^Getopt\(#.*\)\?: /
      echohl Error | echo v:exception | echohl None

   endtry

endfunc

" Function:  _Get_input {{{2
" Purpose:   Ask the user to input each global and individual option, then
"            validate it. If the 'input' list of options is given, this is
"            used instead of user input
" Arguments: a Getopt#Filetype object
" Return:    N/A. Filetype object is modified in-place
function Getopt#_Get_input( buffer_ft )

   " Make sure there aren't leftovers from the last run!
   if ( !empty( a:buffer_ft.opt_data ) || !empty( a:buffer_ft.global_data ) )
      throw "Getopt: Invalid call to Getopt#Get_input: data has not been Save()d"
   endif

   " Data may be entered non-interactively through the .input list
   if ( exists( "a:buffer_ft.input" ) && ! empty( a:buffer_ft.input ) 
            \ && type( a:buffer_ft.input ) != type( [] ) )
      throw "Getopt: Invalid non-interactive input"
   endif

   try
      " Enter global option settings {{{3
      if ! empty( a:buffer_ft.global_keys )

         let global_input = {}

         echo "Single-use data:"

         for this in a:buffer_ft.global_keys
            let global_input[this.name] = ''

            " Read non-interactive input
            if exists( "a:buffer_ft.input" )
               let global_input[this.name] = remove( a:buffer_ft.input, 0 )

            " Read interactive input, possibly with a default arg
            elseif exists( "this.default" )
               let global_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ', 
                                 \ this.default )
            else
               let global_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ' )
            endif
         endfor

         " Validate input
         if a:buffer_ft.validate_global( global_input )
            let a:buffer_ft.global_opts = global_input
         else
            throw "Invalid global data entered"
         endif

      endif

      " Enter settings for each option {{{3

      if empty( a:buffer_ft.opt_keys )
         throw "No option information is defined. Nothing to do"
      endif

      echo "Per-option data:"
      echo "Press ^C to finish"
      while (1)

         let opt_input = {}
         for this in a:buffer_ft.opt_keys
            let opt_input[this.name] = ''

            " Read non-interactive input
            if exists( "a:buffer_ft.input" )
               let opt_input[this.name] = remove( a:buffer_ft.input, 0 )

            " Read interactive input, possibly with a default arg
            elseif exists( "this.default" )
               let opt_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ', 
                                 \ this.default )
            else
               let opt_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ' )
            endif
         endfor

         " Validate input
         if a:buffer_ft.validate( opt_input )
            let a:buffer_ft.opts += [ opt_input ]
            echo "Option recorded"
         else
            echomsg "Invalid option ignored"
         endif

      endwhile

      " }}}3

   catch /^\(Vim:Interrupt\|E684\)/
      " Valid end of input
   " other exceptions escalate to Getopt#Run
   endtry

endfunc

" Function:  _Rename_for_input {{{2
" Purpose:   Make some simple substitutions to variable names before display
"            in input prompts
"  Examples: arg -> arg
"            the_thing -> the thing
"            does_foo -> does foo?
" Arguments: A single option name
" Return:    The option name, possibly slightly modified
function Getopt#_Rename_for_input( var )
   let var = a:var

   let pattern = [ 
            \ '_', ' ',
            \ '^\(is\|has\|does\).*$', '&?'
            \ ]

   for i in range( 0, len(pattern), 2 )
      let var = substitute( var, pattern[i], pattern[i+1] )
   endfor

   return var
endfunc

" Function:  Test {{{2
" Purpose:   Perform some basic tests of the filetype plugin of the current
"            file. It should test that each of the functions exist, that
"            function set appropriate Getopt members, return appropriate
"            values, and fail where appropriate.
" Arguments: boolean whether to run interactively (for unit testing). The only
"            change is that in non-interactive mode results won't be displayed
" Return:    The name of the file where VimTAP wrote test results
function Getopt#Test( interactive )
   let result_file = tempname()

   try
      call vimtap#SetOutputFile(result_file)
      call vimtap#Plan(20)

      " Getopt#{ft}#ft.New() runs properly (x2) {{{3
      let init_fn = "Getopt#" . &ft . "#ft.New()"

      try
         let test_ft = g:Getopt#{&ft}#ft.New()
         call vimtap#Pass( init_fn . " is defined and runs" )
      catch /E117/
         call vimtap#BailOut( init_fn . " is not defined. Can't continue." )
      catch
         call vimtap#BailOut( init_fn . " threw exception\n"
                  \ . '"' . v:exception . '"' )
      endtry

      try
         call g:Getopt#{&ft}#ft.New(1)
         call vimtap#Fail( init_fn . " takes no arguments" )
      catch
         call vimtap#Like( v:exception, 'E118', 
                  \ init_fn . " takes no arguments" )
      endtry

      " opt_keys and global_keys are set and correct (x5) {{{3

      " opt_keys
      call vimtap#Ok( ! empty( test_ft.opt_keys ), init_fn . " sets opt_keys" )
      call vimtap#Is( type( test_ft.opt_keys ), type( [] ), "opt_keys is a list" )

      try
         call vimtap#Is( Getopt#_Test_data( test_ft.opt_keys ), [], 
                  \ "contents of opt_keys are valid" )
      catch
         call vimtap#BailOut( '_Test_data threw exception "' . v:exception . '"' )
      endtry

      " global_keys
      if ( ! vimtap#Skip(2, ! empty( test_ft.global_keys ),
               \ "Don't run tests on unset global_keys" ) )

         call vimtap#Is( type( test_ft.global_keys ), type( [] ), "global_keys is a list" )

         try
            call vimtap#Is( Getopt#_Test_data( test_ft.global_keys ), [],
                     \ "contents of global_keys are valid" )
         catch
            call vimtap#BailOut( '_Test_data threw exception "' . v:exception . '"' )
         endtry
      endif

      " (important) all functions are defined (x4) {{{3

      let stat = 1 " all functions must exist or we fail
      let stat = stat * vimtap#Ok( exists( "test_ft.Validate" ), "Validate() is defined" )
      let stat = stat * vimtap#Ok( 
               \ exists( "test_ft.Validate_global" ) || empty( test_ft.global_keys ), 
               \ "Validate_global() is defined/global keys aren't used" )
      let stat = stat * vimtap#Ok( exists( "test_ft.Write" ), "Write() is defined" )

      if stat == 0
         call vimtap#BailOut( "Functions don't exist. Can't continue." )
      endif

      " Validate works (to limits of testing) (x4) {{{3

      " requires one argument
      try
         call test_ft.Validate()
         call vimtap#Fail( "Validate() requires an argument" )
      catch
         call vimtap#Like( v:exception, 'E119',
                  \ "Validate() requires an argument" )
      endtry

      try
         call test_ft.Validate(1,2)
         call vimtap#Fail( "Validate() takes a single argument" )
      catch
         call vimtap#Like( v:exception, 'E118',
                  \ "Validate() takes a single argument" )
      endtry

      " allows a hash argument
      try
         call test_ft.Validate( {} )
         call vimtap#Pass( "Validate() can take a dict argument" )
      catch
         call vimtap#Fail( "Validate() can take a dict argument" )
      endtry

      " fails on empty input
      let test_data = {}
      for item in test_ft.opt_keys
         let test_data[item.name] = ''
      endfor
      call vimtap#Ok( !test_ft.Validate( test_data ), 
               \ "Validate() fails on empty input" )

      " Validate_global works (to limits of testing) (x4) {{{3
      if ( ! vimtap#Skip( 3, !empty( test_ft.global_keys ),
               \ "Don't run tests on unset global_keys" ) )

         " requires one argument
         try
            call test_ft.Validate_global()
            call vimtap#Fail( "Validate_global() requires an argument" )
         catch
            call vimtap#Like( v:exception, 'E119',
                     \ "Validate_global() requires an argument" )
         endtry

         try
            call test_ft.Validate_global(1,2)
            call vimtap#Fail( "Validate_global() takes a single argument" )
         catch
            call vimtap#Like( v:exception, 'E118',
                     \ "Validate_global() takes a single argument" )
         endtry

         " allows a hash argument
         try
            call test_ft.Validate_global( {} )
            call vimtap#Pass( "Validate_global() can take a dict argument" )
         catch
            call vimtap#Fail( "Validate_global() can take a dict argument" )
         endtry

         " fails on empty input 
         let test_data = {}
         for item in test_ft.global_keys
            let test_data[item.name] = ''
         endfor
         call vimtap#Ok( !test_ft.Validate_global( test_data ), 
                  \ "Validate() fails on empty input" )

      endif

      " Write works (to limits of testing) {{{3
      try
         call test_ft.Write(1)
         call vimtap#Fail( "Write() takes no arguments" )
      catch
         call vimtap#Like( v:exception, 'E118',
                  \ "Write() takes no arguments" )
      endtry

      " }}}3

      call vimtap#Diag( "Automated testing cannot test whether Validate(), Validate_global(),\n"
               \ . "and Write() work as expected. That's up to you." )

      call vimtap#FlushOutput()

   catch /E117: .*: vimtap/
      echo "Getopt: VimTAP is not installed. Cannot perform tests"
   catch /\(VimTAP:BailOut\)\@!/
      " NB: do not match BailOut exceptions. Docs threaten hauntings by "all
      " the devils of the lower hells" if I do
      echo "Abort: Testing failed with exception\n"
               \ . '"' . v:exception . '" at ' . v:throwpoint
   endtry

   " Display the results
   if ( a:interactive )
      silent exe 'sview' result_file
      setlocal nomodifiable
   endif

   return result_file

endfunc

" Function:  _Test_data {{{2
" Purpose:   test that the argument is a list of hashes, each hash
"            containing the keys 'name' and possibly 'default'
" Arguments: opt_keys or global_keys
" Return:    list of keys which failed for one reason or another
function Getopt#_Test_data( data )
   let failures = []

   for item in a:data

      " Check it's a hash
      if ( type( item ) != type( {} ) )
         call add( failures, item )
         continue
      " Check it contains a 'name'
      elseif ! exists( "item['name']" )
         call add( failures, item )
         call remove( item, 'name' ) " for warning about unknown keys below
      endif

      " Warn about unknown keys
      if exists( "item['default']" )
         call remove( item, 'default' )
      endif
      if ! empty( item )
         call vimtap#Diag( "item contains unknown keys: "
                  \ . sort( keys( item ) ) . ". Did you want this?" )
      endif

   endfor

   return failures
endfunc
" }}}1

" Reset line continuation to user's settings
let &cpo = s:save_cpo
