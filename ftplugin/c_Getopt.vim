" c_Getopt:      Define a filetype-specific function for Getopts. See
"                documentation in Getopt.txt
" Author:        Patrick Conley <patrick.bj.conley@gmail.com>
" Last Changed:  2012 Feb 29
" License:       This plugin (and all assoc. files) are available under the same
"                license as Vim itself.
" Documentation: see Getopt.txt

if !exists( "Getopt.c" )
	function Getopt.c() dict

		echo "This is a template function only"
		echo "Lang: " . self.ft
		echo self.opts

	endfunc
endif
