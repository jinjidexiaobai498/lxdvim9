vim9script

import "./global.vim" as g

def ClosePair(char: string): string
	if getline('.')[col('.') - 1] == char
		return "\<Right>"
	else
		return char
	endif
enddef

def PairMatch()
	inoremap ( ()<ESC>i
	inoremap ) <c-r>=<SID>ClosePair(')')<CR>
	inoremap { {}<ESC>i
	inoremap } <c-r>=<SID>ClosePair('}')<CR>
	inoremap [ []<ESC>i
	inoremap ] <c-r>=<SID>ClosePair(']')<CR>
	inoremap " ""<ESC>i
	inoremap ' ''<ESC>i
enddef

def ToggleLsp()
	if !g.lsp_status 
		call lsp#enable()
		g.lsp_status = true return
	endif
	call lsp#disable()
	g.lsp_status = false
enddef
export def BasicKeymap()
	inoremap jk <Esc>
	tnoremap jk <C-\><C-n>

	PairMatch()

	# 回车即选中当前项
	inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"             
	nmap <leader>ee :e $MYVIMRC<cr>
	nmap <silent> <leader>bn :bn<CR>
	nmap <silent> <leader>bp :bp<CR>
	nmap <silent> q :bdelete<CR>
	nmap <silent> s :w !sudo tee "%"<CR>

	nmap <silent> <c-q> :bwipeout<CR>
	nmap <silent> <c-s> :w<CR>

	# emulater Emacs keybinding
	# alt = 
	inoremap i <ESC>I inoremap a <ESC>A inoremap <c-f> <Right>
	inoremap <c-b> <Left>
	#inoremap <c-k> <ESC>d$a
	nmap <C-n> :20Lexplore<cr>
enddef

export def BasicPluginKeymap()
	nmap ,t :TaskList<CR>
	nmap ,n :NERDTreeToggle<CR>
	nmap ,d :NERDTreeFind<CR>
	nmap ,s :TagbarToggle<CR>
	nmap ,p <Plug>PSLPopupBrowser
	nmap <leader>p <Plug>PSLPopupBrowser
	nmap <leader>ss <Plug>PSLSave
	nmap <leader>th <Plug>HortTerminalToggle
	nmap <leader>tv <Plug>VertTerminalToggle
	tnoremap <leader>th <Plug>HortTerminalToggle
	tnoremap <leader>tv <Plug>VertTerminalToggle

	nmap <C-\> <Plug>VertTerminalToggle

	nmap <C-l> <Plug>HortTerminalToggle
	tnoremap <C-\> <Plug>VertTerminalToggle
	tnoremap <C-l> <Plug>HortTerminalToggle

	if executable('lazygit')
		nmap ,g :!lazygit<CR>
	endif
enddef

export def PluginKeymap(flag = true)
	if !flag
		return
	endif

	#find 
	nmap <leader>ft :BTag<CR>
	nmap <leader>fT :Tags<CR>
	nmap <leader>ff :Files<CR> 
	nmap <leader>fl :BLines<CR> 
	nmap <leader>fL :Lines<CR>

	# find by word under current cursor 
	nmap <leader>fs :execute ":BTag " . expand('<cword>')<CR>
	nmap <leader>fS :execute ":Tags " . expand('<cword>')<CR>
	nmap <leader>fw :execute ":BLines " . expand('<cword>')<CR>
	nmap <leader>fW :execute ":Lines " . expand('<cword>')<CR>

	nmap <C-p> :Maps<CR>

	nmap ,f :Files<CR>
	nmap ,l :Lines<CR>
	
	LspKeymapLoad()

enddef
def LspKeymapLoad()
	if !get(g:, '__plug_extend_flag__', false)
		return
	endif
	# lsp prefix
	nmap <leader>lt :call <SID>ToggleLsp()<CR>
	nmap <leader>lr :LspRename<CR>
	nmap <leader>lc :LspCodeLens<CR>
	nmap <leader>la :LspCodeAction<CR>
	nmap <leader>lh :LspHover<CR>
	nmap <leader>lj :LspNextDiagnostic<CR>
	nmap <leader>lk :LspPreviousDiagnostic<CR>
	nmap gd :LspDefinition<CR>
	nmap gr :LspReferences<CR>
enddef
