vim9script
&encoding = 'utf-8'

import "./global.vim" as g

export def InstallPlugVim(): bool

	var using_neovim = g.use_neovim
	var vim_plug_just_installed = false
	var vim_plug_path = g.vim_plug_path

	if !filereadable(vim_plug_path)
		echom "Installing Vim-plug..."
		if using_neovim
			silent !mkdir -p ~/.config/nvim/autoload
			silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		else
			silent !mkdir -p ~/.vim/autoload
			silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		endif
		vim_plug_just_installed = true
	endif
	

	# manually load vim-plug the first time
	if vim_plug_just_installed
		:execute 'source ' .. fnameescape(vim_plug_path)
	endif

	# active vim-plug
	call plug#begin("~/.vim/plugged")
	call plug#end()
	return vim_plug_just_installed

enddef


export def PlugLoad(is_just_install: bool)
	var  is_installed_plugins = g.is_installed_plugins 
	call plug#begin("~/.vim/plugged")

	Plug 'liuchengxu/vim-which-key'
	# On-demand lazy load
	Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

	nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
	#nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

	Plug 'prabirshrestha/vim-lsp'
	Plug 'mattn/vim-lsp-settings'

	#Plug 'prabirshrestha/asyncomplete.vim'
	#Plug 'prabirshrestha/asyncomplete-lsp.vim'
	#inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
	#inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
	#inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
	# imap <c-space> <Plug>(asyncomplete_force_refresh)
	# For Vim 8 (<c-@> corresponds to <c-space>):
	# imap <c-@> <Plug>(asyncomplete_force_refresh)
	# allow modifying the completeopt variable, or it will
	# be overridden all the time
	# let g:asyncomplete_auto_completeopt = 0
	# set completeopt=menuone,noinsert,noselect,preview

	# Airline
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	# Code and files fuzzy finder
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
	Plug 'junegunn/fzf.vim'
	# Code commenter
	Plug 'scrooloose/nerdcommenter'
	# A couple of nice colorschemes
	# Plug 'fisadev/fisa-vim-colorscheme'
	Plug 'patstockwell/vim-monokai-tasty'
	# Nice icons in the file explorer and file type status line.
	Plug 'ryanoasis/vim-devicons'
	# Better file browser
	Plug 'scrooloose/nerdtree'
	# Class/module browser
	Plug 'majutsushi/tagbar'
	# Surround
	Plug 'tpope/vim-surround'
	# Generate html in a simple way
	Plug 'mattn/emmet-vim'
	# Paint css colors with the real color
	Plug 'lilydjwg/colorizer'
	Plug 'fisadev/FixedTaskList.vim'

	call plug#end()

	if is_just_install || is_installed_plugins
		echo "Installing Bundles, please ignore key map error messages"
		:PlugInstall
	endif

enddef

# Fancy Symbols!!
def FancySymbolsEnable(is_enabled: bool)
	if !is_enabled
		return
	endif

	g:webdevicons_enable = 1
	# custom airline symbols
	if !exists('g:airline_symbols')
		g:airline_symbols = {}
	endif
	g:airline_left_sep = ''
	g:airline_left_alt_sep = ''
	g:airline_right_sep = ''
	g:airline_right_alt_sep = ''
	g:airline_symbols.branch = '⭠'
	g:airline_symbols.readonly = '⭤'
	g:airline_symbols.linenr = '⭡'
enddef

export def BasicPluginConfig()

	# Enable folder icons
	g:WebDevIconsUnicodeDecorateFolderNodes = 1
	g:DevIconsEnableFoldersOpenClose = 1
	# Fix directory colors
	highlight! link NERDTreeFlags NERDTreeDir
	# Remove expandable arrow
	g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
	g:WebDevIconsUnicodeDecorateFolderNodes = v:true
	g:NERDTreeDirArrowExpandable = "\u00a0"
	g:NERDTreeDirArrowCollapsible = "\u00a0"
	g:NERDTreeNodeDelimiter = "\x07"
	# Airline ------------------------------
	g:airline_powerline_fonts = 0
	g:airline_theme = 'bubblegum'
	g:airline#extensions#whitespace#enabled = 0
	# Tagbar
	g:tagbar_autofocus = 1
	FancySymbolsEnable(true)
	colorscheme vim-monokai-tasty
enddef
