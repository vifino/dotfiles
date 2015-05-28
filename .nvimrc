" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
	set nobackup		" do not keep a backup file, use versions instead
else
	set backup		" keep a backup file (restore to previous version)
	set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.	Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
	set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
	au!

	" For all text files set 'textwidth' to 78 characters.
	autocmd FileType text setlocal textwidth=78

	autocmd FileType elixir set noet si pi sts=0 sw=2 ts=2
	" When editing a file, always jump to the last known cursor position.
	" Don't do it when the position is invalid or when inside an event handler
	" (happens when dropping a file on gvim).
	" Also don't do it when the mark is in the first line, that is the default
	" position when opening a file.
	autocmd BufReadPost *
		\ if line("'\"") > 1 && line("'\"") <= line("$") |
		\		exe "normal! g`\"" |
		\ endif

	augroup END

else

	set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
	command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
			\ | wincmd p | diffthis
endif

" Custom stuff :D
augroup reload_vimrc " {
	autocmd!
	autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END "
set noet si pi sts=0 sw=2 ts=2
set title
set nu
set runtimepath+=~/.nvim/bundle/neobundle.vim/
set nobackup
call neobundle#begin(expand('~/.nvim/bundle/'))
" Bundeling! :D

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\			'windows' : 'tools\\update-dll-mingw',
\			'cygwin' : 'make -f make_cygwin.mak',
\			'mac' : 'make -f make_mac.mak',
\			'linux' : 'make',
\			'unix' : 'gmake',
\		 },
\ }
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'fatih/vim-go'
NeoBundle 'edkolev/promptline.vim'
NeoBundle 'MarcWeber/vim-addon-mw-utils'
NeoBundle 'tomtom/tlib_vim'
NeoBundle 'Shougo/neocomplcache.vim'
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_dictionary_filetype_lists = {
		\ 'default' : '',
		\ 'vimshell' : $HOME.'/.vimshell_hist',
		\ 'scheme' : $HOME.'/.gosh_completions'
	\ }
NeoBundle 'honza/vim-snippets'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'wlangstroth/vim-racket'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'bling/vim-airline' " Vim Airline
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
NeoBundle 'Shougo/vimshell.vim'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'mattn/gist-vim'
NeoBundle 'wting/rust.vim'
NeoBundle 'severin-lemaignan/vim-minimap'
NeoBundle 'edkolev/tmuxline.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'elixir-lang/vim-elixir'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'PotatoesMaster/i3-vim-syntax'
"NeoBundle 'jtratner/vim-flavored-markdown'
NeoBundle 'gabrielelana/vim-markdown'
" set background=dark
let g:indent_guides_enable_on_vim_startup = 1
let g:gist_detect_filetype = 1

" Done Bundeling!
call neobundle#end()
NeoBundleCheck
syntax on
colorscheme tir_black

set noet ci pi sts=0 sw=2 ts=2 " vifino <3 Tabs

" printer stuffs.
"let &printexpr="(v:cmdarg=='' ? ".
"    \"system('lpr' . (&printdevice == '' ? '' : ' -P' . &printdevice)".
"    \". ' ' . v:fname_in) . delete(v:fname_in) + v:shell_error".
"    \" : system('mv '.v:fname_in.' '.v:cmdarg) + v:shell_error)"

