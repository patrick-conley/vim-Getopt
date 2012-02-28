PLUGIN = Getopt

SOURCE = doc/test.txt
SOURCE += plugin/test.vim

all: build install

build: ${SOURCE}
	vim --cmd 'let g:plugin_name="${PLUGIN}"' -s ../build.vim

install:
	vim -s ../install.vim ${PLUGIN}.vba

clean:
	vim --cmd 'let g:plugin_name="${PLUGIN}.vba"' -s ../clean.vim
	rm ${PLUGIN}.vba
