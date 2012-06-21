" Getopt:        write fairly simple (but potentially lengthy) options parsing
"                for various languages
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Jun 20
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
" declared in the filetype's autoloaded module.

let Getopt#Filetype = {}

" Method: .New( [ $ft ] ) {{{3
" Purpose: Create a new Filetype object
" Arguments: N/A
" Assumptions: N/A
" Validation: 
"  - FT module for current filetype must exist
"  - FT module must contain appropriate keys:
"    - non-empty hash opt_keys & function Validate()
"    - function Validate_global() if non-empty hash global_keys
"    - function Write()
function Getopt#Filetype.New() dict
   let filetype = a:0 == 1 ? a:1 : &ft

   let new_ft = {}
   let new_ft.Save = self.Save
   let new_ft.HasData = self.HasData
   let new_ft.SetInputList = self.SetInputList
   call self.Init( new_ft )

   " Add the filetype functions to the object
   try
      call extend( new_ft, g:Getopt#{&ft}#ft.New() )
      unlet new_ft.New " The FT object doesn't need the FT module's constructor
   catch /E121/
      throw "Getopt#Filetype: Filetype module " . &ft . " undefined."
   endtry

   " Double-check opt_keys is set
   if empty( new_ft.opt_keys )
      throw "Getopt#Filetype: opt_keys not set by Getopt#" . &ft . "#ft.New()"
   endif

   return new_ft
endfunc

" Method: .Init( %Ft_obj ) {{{3
" Purpose: Initialize the member variables of a new Filetype object
" Arguments: The FT object to be initialized
" Assumptions: 
"  - the type of each member has not been changed (could only occur if this
"  has been re-called on an existing object)
" Validation: N/A
function Getopt#Filetype.Init( new_ft ) dict
   let a:new_ft.global_keys = []
   let a:new_ft.opt_keys = []

   let a:new_ft.global_data = {}
   let a:new_ft.opt_data = []
   let a:new_ft.last_global = {}
   let a:new_ft.last_data = []
endfunc

" Method: .Compare( %Ft_obj ) {{{3
" Purpose: Check that the given object is a valid filetype object (contains
" the appropriate keys and the keys are of appropriate types)
" Arguments:
"  - A dict to be compared
"     Assumptions:
"     - argument is a dict
"     Validation:
"     - N/A
function Getopt#Filetype.Compare( obj ) dict

   " members that should exist {{{4
   let required_members = [ "Save", "HasData", "SetInputList", "Validate",
            \ "Write", "opt_keys", "global_keys", "opt_data", "global_data",
            \ "last_data", "last_global" ]
   let required_types = [ 2, 2, 2, 2, 2, 3, 3, 3, 4, 3, 4 ]

   let optional_members = [ "Validate_global", "input" ]
   let optional_types = [ 2, 3 ]

   " Test required member variables exist {{{4
   for i in range( len( required_members ) )
      if !exists( "a:obj." . required_members[i] )
         return 0
      endif
   endfor

   " Test all members have the right type {{{4
   let all_members = extend( copy( required_members ), optional_members )
   let all_types = extend( copy( required_types ), optional_types )

   for i in range( len( all_members ) )
      if exists( "a:obj." . all_members[i] ) &&
               \ type( a:obj[all_members[i]] ) != all_types[i]
         return 0
      endif
   endfor

   " }}}4

   return 1
endfunc

" Method: .Save() {{{3
" Purpose: Copy self to the hash of saved FT objects in Getopt#Saved
" Assumptions: N/A
" Validation: N/A
function Getopt#Filetype.Save() dict
   if ( ! empty( self.global_data ) || ! empty( self.opt_data ) )
      let self.last_global = self.global_data
      let self.global_data = {}

      let self.last_data = self.opt_data
      let self.opt_data = []

      call g:Getopt#Saved.SetFt( &ft, self )
   endif
endfunc

" Method: .HasData() {{{3
" Purpose: Check whether opt_data or global_data is non-empty
" Assumptions:
"  - none of the members have been completely deleted
" Validation: N/A
function Getopt#Filetype.HasData() dict
   if empty( self.opt_data )
      return 0
   elseif ! empty( self.global_keys ) && empty( self.global_data )
      return 0
   endif

   return 1
endfunc

" Method: .SetInputList( @input ) {{{3
" Purpose: Assign a list of input to be used in a non-interactive mode by
"          Getopt#_Get_input()
" Assumptions: N/A
" Validation:
"  - argument is a list
"  - len(input) = len(global_keys)+n*len(opt_keys) for some n
function Getopt#Filetype.SetInputList( input ) dict

   " Validate the list
   if type( a:input ) != type( [] )
      throw "Getopt#Filetype: Non-interactive input must be a list"
   endif

   " Set the list
   let self.input = a:input
endfunc

" Method: .Validate( %data_hash ) {{{3
" See autoload/Getopt/{ft}.vim


" Method: .Validate_global( %data_hash ) {{{3
" See autoload/Getopt/{ft}.vim


" Method: .Write() {{{3
" See autoload/Getopt/{ft}.vim

" }}}3

" Getopt#Saved {{{2
" Description: A static class meant to store previously-run Getopt#Filetypes
" to allow the reuse of a filetype's data. Access is provided through
" get/set/check functions

let Getopt#Saved = {}

" Method: .Init() {{{3
" Purpose: (Re)initialize the member variable of Getopt#Saved
" Assumptions: N/A
" Validation: N/A
" Note: although only one object of this class should exist, this method
" deliberately fails to check if the data has already been set, as I may need
" to reset the class to a blank state
function Getopt#Saved.Init() dict
   let self.ft_dict = {}
endfunc

" Method: .SetFt( $ft, %ft_obj ) {{{3
" Purpose: Copy the FT object parameter to the appropriate key of the ft_dict
"          member
" Arguments:
"  - string filetype
"  - FT object
" Assumptions: 
"  - first argument is a string
" Validation:
"  - second argument is a Filetype object
function Getopt#Saved.SetFt( ft, obj ) dict

   " Only allow hashes to be added
   if ! g:Getopt#Filetype.Compare( a:obj )
      throw "Getopt#Saved: input must be a Filetype object"
   endif

   let self.ft_dict[a:ft] = a:obj
endfunc

" Method: GetFt( $ft ) {{{3
" Purpose: Return the FT object for a given filetype
" Arguments: string filetype
" Assumptions:
"  - the argument is a legal string
" Validation: N/A
function Getopt#Saved.GetFt( ft ) dict
   if self.CheckFt( a:ft )
      return self.ft_dict[a:ft]
   else
      return
   endif
endfunc

" Method: CheckFt( $ft ) {{{3
" Purpose: Check if ft_dict contains an object for the given filetype
" Arguments: string filetype
" Assumptions:
"  - the argument is a valid string
" Validation: N/A
function Getopt#Saved.CheckFt( ft ) dict
   return has_key( self.ft_dict, a:ft )
endfunc
" }}}3

call g:Getopt#Saved.Init()

" }}}2
" }}}1

" FUNCTIONS {{{1
" Function:  Run( [ @input ] ) {{{2
" Purpose:   Parse input, run the language-specific functions
" Arguments: 
"  - Non-interactive input (for test cases). 
"    See Getopt#Filetype.SetInputList( [...] )
"    Assumptions: 
"    - N/A
"    Validation:
"    - input must be correct
"    ...
" Return:    Exception messages for standard aborts. Otherwise-uncaught
"            exceptions are echoed
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
         throw "Getopt: No options entered."
      endif

      " Set and print the option string
      let optstr = buffer_ft.Write()

      if empty( optstr )
         throw "Getopt: optstr not set by .Write()"
      endif

      if has_key( buffer_ft, "input" )
         return optstr
      else
         call append( ".", optstr )
         unlet optstr
      endif

      call buffer_ft.Save()

   " Catch: User errors
   catch /^Getopt\(#[^ ]*\)\?: /
      echom substitute( v:exception, "^Getopt\(#[^ ]*\)\?: ", "", "" )
      return v:exception

   " Uncaught: internal errors
   endtry

endfunc

" Function:  _Get_input( %ft_obj ) {{{2
" Purpose:   Ask the user to input each global and individual option, then
"            validate it. If the 'input' list of options is given, this is
"            used instead of user input
" Arguments: 
"  - A Getopt#Filetype object
"    Assumptions:
"    - opt_keys and Validate() are defined; that keys tested by Validate() are
"      a subset of opt_keys
"    - Validate() is set if global_keys is
"    - non-interactive input is an integer multiple of len(opt_keys) (plus
"      len(global_keys) as appropriate)
"    Validation:
"    - opt_keys and global_keys must be valid (each contains a .name)
"    - opt_data and global_data must be empty
" Return:    N/A. Filetype object is modified in-place
function Getopt#_Get_input( buffer_ft )

   " Make sure there aren't leftovers from the last run!
   if ( !empty( a:buffer_ft.opt_data ) || !empty( a:buffer_ft.global_data ) )
      throw "Getopt: Unclean Filetype object passed to _Get_input()"
   endif

   try
      " Enter global option settings {{{3
      if ! empty( a:buffer_ft.global_keys )

         let global_input = {}

         echo "Single-use data:"

         for this in a:buffer_ft.global_keys
            let global_input[this.name] = ''

            " Read non-interactive input
            if has_key( a:buffer_ft, "input" )
               let global_input[this.name] = remove( a:buffer_ft.input, 0 )

            " Read interactive input, possibly with a default arg
            elseif has_key( this, "default" )
               let global_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ', 
                                 \ this.default )
            else
               let global_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ' )
            endif
         endfor

         " Validate input
         if a:buffer_ft.Validate_global( global_input )
            let a:buffer_ft.global_data = global_input
         else
            throw "Getopt: Invalid global data entered"
         endif

      endif

      " Enter settings for each option {{{3

      echo "Per-option data:"
      echo "Press ^C to finish"
      while (1)

         let opt_input = {}
         for this in a:buffer_ft.opt_keys
            let opt_input[this.name] = ''

            " Read non-interactive input
            if has_key( a:buffer_ft, "input" )
               let opt_input[this.name] = remove( a:buffer_ft.input, 0 )

            " Read interactive input, possibly with a default arg
            elseif has_key( this, "default" )
               let opt_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ', 
                                 \ this.default )
            else
               let opt_input[this.name]
                        \ = input( Getopt#_Rename_for_input(this.name) . ' > ' )
            endif
         endfor

         " Validate input
         if a:buffer_ft.Validate( opt_input )
            let a:buffer_ft.opt_data += [ opt_input ]
            echomsg "Option recorded"
         else
            echomsg "Invalid option ignored"
         endif

      endwhile

      " }}}3

   catch /\(^Vim:Interrupt\|E684\)/
      " Valid end of input
   " other exceptions escalate to Getopt#Run
   endtry

endfunc

" Function:  _Rename_for_input( $key_name ) {{{2
" Purpose:   Make some simple substitutions to variable names before display
"            in input prompts
" Examples:  arg -> arg
"            the_thing -> the thing
"            does_foo -> does foo?
" Arguments: 
"  - A single key name
"    Assumptions:
"    - name is a string
"    Validation:
"    - N/A
" Return:    The name, possibly slightly modified
function Getopt#_Rename_for_input( var )
   let var = a:var

   let pattern = [ 
            \ '_', ' ',
            \ '^\(is\|has\|does\).*$', '&?'
            \ ]

   for i in range( 0, len(pattern)-1, 2 )
      let var = substitute( var, pattern[i], pattern[i+1], '' )
   endfor

   return var
endfunc

" Function:  Test( $flag_interactive ) {{{2
" Purpose:   Perform some basic tests of the filetype module of the current
"            file. It should test that each of the functions exist, that
"            function set appropriate Getopt members, return appropriate
"            values, and fail where appropriate.
" Arguments: boolean whether to run interactively (for unit testing). The only
"            change is that in non-interactive mode results won't be displayed
" Return:    The name of the file where VimTAP wrote test results
" TODO:      Test that Write outputs a string or list
function Getopt#Test( interactive )
   let result_file = tempname()

   try
      call vimtap#SetOutputFile(result_file)
      call vimtap#Plan(20)

      try
         echo g:Getopt#{&ft}#ft
      catch /E121/
         call vimtap#BailOut( "No filetype module could be found for filetype '"
                  \ . &ft . "'" )
      endtry

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

      " (important) all functions are defined (x3) {{{3

      let stat = 1 " all functions must exist or we fail
      let stat = stat * vimtap#Ok( has_key( test_ft, "Validate" ), "Validate() is defined" )
      let stat = stat * vimtap#Ok( 
               \ has_key( test_ft, "Validate_global" ) || empty( test_ft.global_keys ), 
               \ "Validate_global() is defined/global keys aren't used" )
      let stat = stat * vimtap#Ok( has_key( test_ft, "Write" ), "Write() is defined" )

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
      if ( ! vimtap#Skip( 4, !empty( test_ft.global_keys ),
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

" Function:  _Test_data( @key_list ) {{{2
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
      elseif ! has_key( item, "name" )
         call add( failures, item )
         call remove( item, 'name' ) " for warning about unknown keys below
      endif

      " Warn about unknown keys
      if has_key( item, "default" )
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
