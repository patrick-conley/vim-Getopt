PLUGIN = Getopt

SOURCE := doc/Getopt.txt
SOURCE += plugin/Getopt.vim
SOURCE += $(wildcard autoload/**.vim)

SOURCEDIRS = doc/ plugin/ autoload/
PATHOGEN := $$HOME/.vim/bundle

ball: build install

pathogen:
	mkdir -p ${PATHOGEN}/${PLUGIN}
	cp -r ${SOURCEDIRS} ${PATHOGEN}/${PLUGIN}

test: 
	./test.sh

build: ${SOURCE}
	@echo "${SOURCE}" | vim - -c "let g:vimball_home = '.'" -c '%s/ //g' -c "execute '%MkVimball!' . '${PLUGIN}'" -c 'qa!'

install:
	vim ${PLUGIN}.vba -c 'so %' -c 'q'

clean:
	vim -c "execute 'RmVimball' '${PLUGIN}'" -c 'q'
	rm -rf ${PATHOGEN}/${PLUGIN}/
	rm -f ${PLUGIN}.vba*

# For internal use only
edit:
	vim plugin/Getopt.vim -c "bel vsp autoload/Getopt.vim " -c "tabe doc/Getopt-internal.txt | bel vsp doc/Getopt.txt" -c "tabe Makefile" -c "tabe autoload/Getopt/matlab.vim | bel vsp autoload/Getopt/c.vim" -c "tabn"

