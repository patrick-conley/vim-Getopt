PLUGIN = Getopt

SOURCE := doc/Getopt.txt
SOURCE += plugin/Getopt.vim
SOURCE += $(wildcard ftplugin/*.vim)

all: build install

build: ${SOURCE}
	@echo "${SOURCE}" | vim --cmd 'let g:plugin_name="${PLUGIN}"' - -s ../build.vim

install:
	vim -s ../install.vim ${PLUGIN}.vba

clean:
	vim --cmd 'let g:plugin_name="${PLUGIN}.vba"' -s ../clean.vim
	rm ${PLUGIN}.vba
	rm ${PLUGIN}.vba~
