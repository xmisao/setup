#!/bin/bash

#################### Functions ####################

function print_nt () {
  echo -en "\033[1;30m[NOTHING TODO]\033[0;39m "
  echo "$1"
}

function print_t () {
  echo -en "\033[1;36m[TODO]\033[0;39m "
  echo "$1"
}

function print_d () {
  echo -en "\033[1;32m[DONE]\033[0;39m "
  echo "$1"
}

function print_f () {
  echo -en "\033[1;31m[FAILED]\033[0;39m "
  echo "$1"
}

function prepend_to () {
  file=$1
  line=$2

  grep "$line" "$file" > /dev/null
  if [ $? -eq 0 ]; then
    print_nt "$line found in $file"
  else
    print_t "$line not found in $file"
    sed -i "1i$line" "$file"
    print_d "$line prepended to $file"
  fi
}

function append_to () {
  file=$1
  line=$2

  grep "$line" "$file" > /dev/null
  if [ $? -eq 0 ]; then
    print_nt "$line found in $file"
  else
    print_t "$line not found in $file"
    echo "$line" >> "$file"
    print_d "$line appended to $file"
  fi
}

function create_file () {
  file=$1
  content=$2
  replace=$3

  if [ -e "$file" ]; then
    if [ -z "$replace" ]; then
      print_nt "$file found"
    else
      if [ "$(cat "$file")" = "$content" ]; then
        print_nt "$file found and content expected"
      else
        print_t "$file should be replace"
        echo "$content" > "$file"
        print_d "$file replaced"
      fi
    fi
  else
    print_t "$file not found"
    echo "$content" > "$file"
    print_d "$file created"
  fi
}

function create_dir () {
  dir=$1

  if [ -d "$dir" ]; then
    print_nt "$dir exists"
  else
    print_t "$dir nof found"
    mkdir -p "$dir"
    print_d "$dir created"
  fi
}

#################### VIM settings ####################

create_file "$HOME/.vimrc" ""

content=$(cat << 'EOS'
" Common settings
set encoding=utf-8
set number
set shiftwidth=2
set softtabstop=2
set tabstop=2
set autoindent
set incsearch
set ignorecase
set expandtab
set ambiwidth=double
set backspace=indent,eol,start
syntax on

" Temp file location settings
set directory=$HOME/tmp/vim
set backupdir=$HOME/tmp/vim

" Markdown file work around
au BufNewFile,BufRead *.md :set filetype=markdown

" Makefile work around / Don't use soft tab
let _curfile=expand("%:r")
if _curfile == 'Makefile'
  set noexpandtab
endif
EOS
)
create_file "$HOME/.vimrc_0" "$content" "replace"
append_to "$HOME/.vimrc" 'source $HOME/.vimrc_0' 

content=$(cat << 'EOS'
" Windows like copy and paste
vnoremap <C-X> "+x
vnoremap <C-C> "+y
map <C-B>   "+gP
cmap <C-B>    <C-R>+
EOS
)
create_file "$HOME/.vimrc_1" "$content" "replace"
append_to "$HOME/.vimrc" 'source $HOME/.vimrc_1' 

content=$(cat << 'EOS'
" Plugins

call plug#begin('~/.vim/plugged')

Plug 'thinca/vim-quickrun'
Plug 'vim-scripts/GrepHere'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'maralla/completor.vim'
Plug 'vim-scripts/wombat256.vim'

call plug#end()
EOS
)
create_file "$HOME/.vimrc_2" "$content" "replace"
append_to "$HOME/.vimrc" 'source $HOME/.vimrc_2' 

content=$(cat << 'EOS'
" Plugins lightline.vim
set laststatus=2

" Plugins completor
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

" 256 Color settings
set t_Co=256

" Colorscheme
colorscheme wombat256mod
EOS
)
create_file "$HOME/.vimrc_3" "$content" "replace"
append_to "$HOME/.vimrc" 'source $HOME/.vimrc_3' 

create_dir "$HOME/tmp/vim"

plug_vim="$HOME/.vim/autoload/plug.vim"
if [ -e "$plug_vim" ]; then
  print_nt "$plug_vim found"
else
  print_t "$plug_vim should be downloaded"

  curl -fLo "$plug_vim" --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  if [ $? -eq 0 ]; then
    print_d "$plug_vim downloaded"
  else
    print_f "$plug_vim not downloaded"
  fi
fi

#################### Bash settings ####################

create_file "$HOME/.bashrc" ""

content=$(cat << 'EOS'
export PS1="\w\ $ "
export EDITOR=vim
export BUNDLE_PATH=$HOME/.bundle
EOS
)
create_file "$HOME/.bashrc_0" "$content" "replace"
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_0'

#################### GNU Screen settings ####################

content=$(cat << 'EOS'
escape ^t^t
caption always "%w"
defbce on
term xterm-256color
shell $SHELL
EOS
)
create_file "$HOME/.screenrc" "$content"

#################### Git settings ####################

content=$(cat << 'EOS'
[user]
  name = xmisao
  email = mail@xmisao.com
EOS
)
create_file "$HOME/.gitconfig" "$content"
