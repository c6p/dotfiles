" vim:fdm=marker
set nocompatible        " break vi compatibility

" NeoBundle {{{
filetype off                  " required
set rtp+=/home/can/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/NeoBundle.vim'
" syntax files
NeoBundle 'dagwieers/asciidoc-vim'
NeoBundle 'vim-scripts/csv.vim'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'vim-scripts/todo-txt.vim'
NeoBundle 'airblade/vim-gitgutter'
" plugins
NeoBundle 'Shougo/vimproc.vim', {'build': {'unix': 'make'}}
NeoBundle 'Shougo/neoyank.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Valloric/YouCompleteMe', {'build': {'unix': './install.py'}}
"NeoBundle 'Shougo/vimfiler.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'vim-scripts/Gundo'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'tpope/vim-dispatch'
"NeoBundle 'sirver/ultisnips'
NeoBundle 'tpope/vim-surround'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'majutsushi/tagbar'
call neobundle#end()
filetype plugin indent on    " required
NeoBundleCheck
" }}}
" General {{{
set vb t_vb=            " visual bell
set history=50          " command history
set showcmd
let mapleader = "\\"
let maplocalleader = ","
set encoding=utf-8
set fileencoding=utf-8
syntax on
filetype on
filetype plugin on
filetype indent on
" }}}
" Editing {{{
set virtualedit=all     " freely move cursor
set mouse=a
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab           " spaces instead of tabs
set backspace=indent,eol,start  " intuitive backspacing in insert mode
" newline - normal mode
map <S-Enter> O<Esc>
map <CR> o<Esc>
" }}}
" GUI preferences {{{
colorscheme lucius " LuciusLight
if has('gui_running')
	set guioptions=acpf
	set guifont=DejaVuSansMono\ 8
    set linespace=1
    set guicursor=a:blinkoff0
    "colorscheme corporation_m
    set columns=91
    set lines=25
    set nu              " line numbers
endif
" }}}
" Search {{{
set incsearch
set ignorecase  " set ignorecase on
set scs         " smart search (override ignoreCase)
set hlsearch    " highlight search terms...
"set 'ncsearch   " ...dynamically as they are typed.
" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
" Command-T
let g:CommandTCancelMap='<Esc>'
" }}}
" Backup {{{
set backupdir=~/.backup//
au BufWritePre * let &bex = '-' . strftime("%Y-%b-%d-%X") . '~'
" let _date = strftime("(%y%m%d-%H)")
" let _date = "set backupext=_". _date
" execute _date
set directory=~/.backup//
set undodir=~/.vim/undo//
let g:openssl_backup = 1
set backup
set undofile
" }}}
" AutoCommands {{{
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END
au BufEnter .auth.aes,*.myf set filetype=myfold
au BufEnter .pentadactylrc set filetype=vim
au BufEnter *.asc set filetype=asciidoc
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
au VimEnter * IndentGuidesEnable
let g:indent_guides_auto_colors = 0
au VimEnter,ColorScheme * :hi IndentGuidesEven ctermbg=254
" close vim if the only window left open is a NERDTree
au bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" }}}
" Shortcuts, Commands {{{
map ,cd :cd %:p:h<CR>:pwd<CR>
command! Cts %s/\s\+$//e         " clear trailing whitespace
" insert current date time
nnoremap <F5> "=strftime("%Y-%m-%d %H:%M")<CR>P
map ,co :Copen<CR>
nnoremap <kPlus>      :cnext<CR>
nnoremap <kMinus>     :cprev<CR>
map ,gg :YcmCompleter GoTo<CR>
map ,ycm :YcmForceCompileAndDiagnostics<CR>
map ,mm :make<CR>
" easy motion
nmap s <Plug>(easymotion-s2)
let g:EasyMotion_smartcase = 1
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
silent! call repeat#set("\<Plug>(easymotion-prefix)", v:count)
" gundo
nnoremap <F6> :GundoToggle<CR>
nnoremap <F7> :NERDTreeToggle<CR>
nmap <F8> :GitGutterToggle<CR>:TagbarToggle<CR>

"call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <leader>bt :Unite buffer file_rec/async -start-insert -buffer-name=new\ tab -default-action=tabopen<CR>
nnoremap <leader>bs :Unite buffer file_rec/async -start-insert -buffer-name=horizontal\ split -default-action=split<CR>
nnoremap <leader>bv :Unite buffer file_rec/async -start-insert -buffer-name=vertical\ split' -default-action=vsplit<CR>
nnoremap <leader>bc :Unite buffer file_rec/async -start-insert -buffer-name=files'<CR>
nnoremap <leader>y :<C-u>Unite -start-insert register history/yank<CR>
nnoremap <space>s :Unite -quick-match buffer<cr>
" }}}
" Visual Cues {{{
set colorcolumn=80
set showmatch       " show last matching bracket
match Todo /\s\+$/  " highlight trailing whitespace
" }}}
" Programming {{{
let &makeprg = 'if [ -f Makefile ]; then make; elif [ -f ../Makefile ]; then make -C ..; elif [ -f build ]; then make -C build; else make -C ../build; fi'

let g:neobundle#install_process_timeout = 1500

let NERDTreeWinPos = "right"
let NERDTreeMouseMode = 3
let NERDTreeIgnore = ['\-$', '\.in$', 'Doxyfile']

let g:gitgutter_enabled = 0
let g:gitgutter_highlight_lines = 1
let g:gitgutter_realtime = 0

let g:neoyank#limit=10000
let g:neoyank#file="~/.vim/yank.txt"

"let g:vimfiler_as_default_explorer = 1

let g:ycm_error_symbol = '!!'
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list=1

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
"cd %:p:h
" makefile in parent directory, if not a sibling
"set makeprg=[[\ -f\ Makefile\ ]]\ &&\ make\ \\\|\\\|\ make\ -C\ ..
" }}}



