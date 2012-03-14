PLUGIN = Getopt

SOURCE := doc/Getopt.txt
SOURCE += plugin/Getopt.vim
SOURCE += $(wildcard autoload/Getopt/*.vim)

all: build install

test: all
	vim -S test.vim

build: ${SOURCE}
	@echo "${SOURCE}" | vim --cmd 'let g:plugin_name="${PLUGIN}"' - -s ../build.vim

install:
	vim -s ../install.vim ${PLUGIN}.vba

edit:
	vim plugin/Getopt.vim -c "bel vsp autoload/Getopt/c.vim" -c "bel sp autoload/Getopt/matlab.vim" -c "tabe doc/Getopt.txt" -c "tabe Makefile" -c "vsp test.vim" -c "tabn"

clean:
	vim --cmd 'let g:plugin_name="${PLUGIN}.vba"' -s ../clean.vim
	rm ${PLUGIN}.vba
	rm ${PLUGIN}.vba~
