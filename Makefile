PLUGIN = Getopt

SOURCE := doc/Getopt.txt
SOURCE += plugin/Getopt.vim
SOURCE += $(wildcard autoload/Getopt/*.vim)

SOURCEDIRS = doc/ plugin/ autoload/
PATHOGEN := $$HOME/.vim/bundle

ball: build install

pathogen:
	mkdir ${PATHOGEN}/${PLUGIN}
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
	vim plugin/Getopt.vim -c "bel vsp autoload/Getopt/c.vim | bel sp autoload/Getopt/matlab.vim" -c "tabe doc/Getopt.txt | bel vsp Makefile" -c "tabe t/autoload/Getopt/t_data.vim | bel vsp t/full.vim | bel sp t/data.vim" -c "tabn"

