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
Plug 'vim-scripts/wombat256.vim'
Plug 'junegunn/fzf', { 'dir': '~/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'posva/vim-vue'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-fugitive'

Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'yami-beta/asyncomplete-omni.vim'

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

call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
      \ 'name': 'omni',
      \ 'whitelist': ['*'],
      \ 'blacklist': ['c', 'cpp', 'html'],
      \ 'completor': function('asyncomplete#sources#omni#completor')
      \  }))

call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
      \ 'name': 'buffer',
      \ 'allowlist': ['*'],
      \ 'blocklist': ['go'],
      \ 'completor': function('asyncomplete#sources#buffer#completor'),
      \ 'config': {
      \    'max_buffer_size': 5000000,
      \  },
      \ }))

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

#################### NVIM settings ####################

create_dir "$HOME/.config/nvim"

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
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes

call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }

" Filer
Plug 'preservim/nerdtree'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

" Syntax
Plug 'nvim-treesitter/nvim-treesitter'

" Complement
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Themes
Plug 'projekt0n/github-nvim-theme'
Plug 'rebelot/kanagawa.nvim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Rails
Plug 'tpope/vim-rails'

" Rust
Plug 'rust-lang/rust.vim'

" Icons for airline
call plug#end()

" Find files using Telescope command-line sugar.
nnoremap fff <cmd>Telescope find_files<cr>
nnoremap ffg <cmd>Telescope live_grep<cr>

" colorscheme github_dark_high_contrast
autocmd VimEnter * colorscheme kanagawa-wave

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1

" NvimTree settings
nmap tt :NvimTreeToggle<CR>

" NERDTree settings
let g:NERDTreeChDirMode=0

" Load coc configuration
source ~/.config//nvim/coc.vim

" Load lua configuration
luafile ~/.config/nvim/config.lua
EOS
)
create_file "$HOME/.config/init.vim" "$content"

content=$(cat << 'EOS'
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

nmap <leader>ac  <Plug>(coc-codeaction-cursor)
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>qf  <Plug>(coc-fix-current)

nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

nmap <leader>cl  <Plug>(coc-codelens-action)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

command! -nargs=0 Format :call CocActionAsync('format')

command! -nargs=? Fold :call     CocAction('fold', <f-args>)

command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
EOS
)
create_file "$HOME/.config/coc.vim" "$content"

content=$(cat << 'EOS'
{
  "languageserver": {
    "solargraph": {
      "command": "solargraph",
      "args": ["stdio"],
      "filetypes": ["ruby"],
      "rootPatterns": [".git", "Gemfile"],
      "initializationOptions": {},
      "settings": {
        "solargraph.completion": true,
        "solargraph.trace.server": "verbose",
        "solargraph.useBundler": true,
        "solargraph.diagnostics": true,
        "solargraph.formatting": true,
        "solargraph.logLevel": "info"
      }
    },
    "godot":{
      "host": "127.0.0.1",
      "port": "6005",
      "filetypes": ["gdscript"]
    }
  }
}
EOS
)
create_file "$HOME/.config/nvim/coc-settings.json" "$content"

content=$(cat << 'EOS'
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  update_root = false,
  hijack_directories = {
    enable = false,
    auto_open = false,
  }
})

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

vim.g.nvim_tree_auto_change_cwd = 0
EOS
)
create_file "$HOME/.config/nvim/config.lua" "$content"

# Install vim-plug for NVIM
# https://github.com/junegunn/vim-plug

plug_nvim="$HOME/.local/share/nvim/site/autoload/plug.vim"
if [ -e "$plug_nvim" ]; then
  print_nt "$plug_nvim found"
else
  print_t "$plug_nvim should be downloaded"
  curl -fLo "$plug_nvim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  if [ $? -eq 0 ]; then
    print_d "$plug_nvim downloaded"
  else
    print_f "$plug_nvim not downloaded"
  fi
fi

# Install GitHub copilot
# https://docs.github.com/ja/copilot/getting-started-with-github-copilot?tool=vimneovim

copilot=$HOME/.config/nvim/pack/github/start/copilot.vim
if [ -e "$copilot" ]; then
  print_nt "$copilot found"
else
  print_t "$copilot should be downloaded"
  git clone https://github.com/github/copilot.vim $copilot
  if [ $? -eq 0 ]; then
    print_d "$copilot downloaded"
  else
    print_f "$copilot not downloaded"
  fi
fi
