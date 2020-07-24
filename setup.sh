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
set hlsearch
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
call plug#begin('~/.vim/plugged')

Plug 'thinca/vim-quickrun'
Plug 'vim-scripts/GrepHere'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
" Plug 'maralla/completor.vim', { 'commit': 'abed3d3720d7186920f2e28d81e43749104e80bb' }
Plug 'vim-scripts/wombat256.vim'
Plug 'junegunn/fzf', { 'dir': '~/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'posva/vim-vue'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-fugitive'

" Vim LSP
" Plug 'prabirshrestha/vim-lsp'
" Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
" Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'

call plug#end()
EOS
)
create_file "$HOME/.vimrc_2" "$content" "replace"
append_to "$HOME/.vimrc" 'source $HOME/.vimrc_2' 

content=$(cat << 'EOS'
" Plugins lightline.vim
set laststatus=2

" asynccomplete.vim
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" 256 Color settings
set t_Co=256

" Colorscheme
colorscheme wombat256mod

" Plugins fzf
nmap ff :FZF<CR>
nmap fr :Rg<CR>
nmap fl :Lines<CR>

" Auto QuickFix when grep
autocmd QuickFixCmdPost *grep* cwindow
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
export EDITOR=vim
export BUNDLE_PATH=$HOME/.bundle

alias ls="ls --color"
alias grep="grep --color"
alias b="bundle"
alias g="git"
alias less="less -R"
EOS
)
create_file "$HOME/.bashrc_0" "$content" "replace"
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_0'

content=$(cat << 'EOS'
# FIXME Support multi screen process

# Screen Change Directory
function scd () {
  screen -X "eval" "chdir $PWD"
  echo "Set screen dir to $PWD"
}

# Screen New Window in current directory
function snw () {
  screen_pid=$(ps f | grep screen | grep -v grep | awk '{print $1}')
  screen_current_dir=$(readlink -f /proc/$screen_pid/cwd)
  screen -X "eval" "chdir $PWD" screen
  screen -X "eval" "chdir $screen_current_dir"
  echo "Open new window $PWD"
}
EOS
)
create_file "$HOME/.bashrc_1" "$content" "replace"
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_1'

content=$(cat << 'EOS'
function super_open () {
  path="$1"

  if [ -f "$path" ]; then
    "$EDITOR" "$path"
  fi

  if [ -d "$path" ]; then
    cd "$path"
  fi

  echo $path
}

function H () {
  dir=$(cd "$HOME"; find . -maxdepth 1 -type d | fzf)

  echo

  if [ -z "$dir" ]; then
    :
  else
    super_open "$HOME/$dir"
  fi
}

function F () {
  path=$(find . -maxdepth 4 \
    -type d -name .bunlde -prune -o \
    -type d -name bundle -prune -o \
    -type d -name .vim -prune -o \
    -type d -name .git -prune -o \
    -print | fzf)

  echo

  if [ -z "$path" ]; then
    :
  else
    super_open "$path"
  fi
}
EOS
)
create_file "$HOME/.bashrc_2" "$content" "replace"
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_2'

content=$(cat << 'EOS'
function colorful () {
  front_color=$1
  back_color=$2

  case "$front_color" in
    'black' ) f='0;30' ;;
    'red' ) f='0;31' ;;
    'green' ) f='0;32' ;;
    'yellow' ) f='0;33' ;;
    'blue' ) f='0;34' ;;
    'magenta' ) f='0;35' ;;
    'cyan' ) f='0;36' ;;
    'white' ) f='0;37' ;;
    'bold_black' ) f='1;30' ;;
    'bold_red' ) f='1;31' ;;
    'bold_green' ) f='1;32' ;;
    'bold_yellow' ) f='1;33' ;;
    'bold_blue' ) f='1;34' ;;
    'bold_magenta' ) f='1;35' ;;
    'bold_cyan' ) f='1;36' ;;
    'bold_white' ) f='1;37' ;;
  esac

  if [ -z $back_color ];then
    echo -en "\033[${f}m"
  else
    case "$back_color" in
      'black' ) b=40 ;;
      'red' ) b=41 ;;
      'green' ) b=42 ;;
      'yellow' ) b=43 ;;
      'blue' ) b=44 ;;
      'magenta' ) b=45 ;;
      'cyan' ) b=46 ;;
      'white' ) b=47 ;;
    esac

    echo -en "\033[${f};${b}m"
  fi
}

break_color="\033[0;39m"

# Config *********************************
disable_host_name=
host_name=$(hostname)

host_name_color=$(colorful 'black' 'white')
dir_color=$(colorful 'white')
dollar_color=$(colorful 'bold_white')
# ****************************************

if [ -z $disable_host_name ]; then
  export PS1="${host_name_color}[${host_name}]${break_color} ${dir_color}\w${break_color} ${dollar_color}\$${break_color} "
else
  export PS1="${dir_color}\w${break_color} ${dollar_color}\$${break_color} "
fi
EOS
)
create_file "$HOME/.bashrc_prompt" "$content"
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_prompt'

create_file "$HOME/.bashrc_ext" ""
append_to "$HOME/.bashrc" 'source $HOME/.bashrc_ext'

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
