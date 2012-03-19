getopt.vim
==========

Any time I need to write option-parsing code in some obsure language, I either
copy it from my last project in that language, or spend three hours looking at
man pages to work out the syntax (and that only if I can't find any code in the
language I'm using).

getopt.vim is meant to remember how to write option code, so I don't have to.
When I call it with `:Getopt`, it will prompt me for various pieces of
information, then spit out appropriate code.

See further down for examples in a few languages.

Installation
------------

It's most easy to install Getopt with
[pathogen](https://github.com/tpope/vim-pathogen).

If you have a copy of GNU make (or something reasonably similar) the Makefile
can take care of installation through pathogen with

    make pathogen

or through a Vimball with

    make ball

Be warned that `make pathogen` only installs to `~/.vim/bundle/Getopt`.

Or just clone the whole thing wherever you like with

    git clone git@github.com:patrick-conley/vim-Getopt.vim

Examples
--------

In all these examples, bold text has been entered by the user. These examples
are also only meant to be illustrative! Whether or not Getopt acts as shown
depends on what functionality I've written and whether this readme is up to
date.

In sh (let's call it `Getopt-test.sh`):

    *:Getopt*
    option > *h*
    has arg? > 
    action > *help()*
    -----
    option > *i*
    has arg? > *1*
    variable > *infile*
    -----
    option > *x*
    has arg? >
    action >
    -----
    option > *^C*

prints
   
    while getopts ":hi:x" flag; do
        case $flag in
            h) help() ;;
            i) infile=$OPTARG ;;
            x) ;; # do something
            \?) echo 'usage: Getopt-test.sh [ -h ] [ -x ] [ -i infile ]' && exit 1
        esac
    done
    shift $(($OPTIND - 1))

In Perl

    *:Getopt*
    option > *file*
    default > 
    optional > *1*
    type > *SCALAR*
    -----
    option > *verbosity*
    default > 0
    type > SCALAR | UNDEF

prints

    my %options = validate( @&uscore;, {
        file => { optional => 1, type => SCALAR },
        verbosity => { default => 0, type => SCALAR | UNDEF }
    } );

I also support/plan to support C and Matlab/Octave. By now you can probably
guess what kind of things will happen in those languages.

License
-------

This plugin is available under the same terms as Vim. See `:help license`.
