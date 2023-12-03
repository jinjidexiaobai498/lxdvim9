vim9script
import "./global.vim" as g

def ClosePair(char: string): string
	if getline('.')[col('.') - 1] == char
		return "\<Right>"
	else
		return char
	endif
enddef

def ToggleLsp()
	if !g.lsp_status 
		call lsp#enable()
		g.lsp_status = true
		return
	endif
	call lsp#disable()
	g.lsp_status = false

enddef

export def UsefulKeymapLoad()

	# 回车即选中当前项
	inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"             
	inoremap ( ()<ESC>i
	inoremap ) <c-r>=<SID>ClosePair(')')<CR>
	inoremap { {}<ESC>i
	inoremap } <c-r>=<SID>ClosePair('}')<CR>
	inoremap [ []<ESC>i
	inoremap ] <c-r>=<SID>ClosePair(']')<CR>
	inoremap " ""<ESC>i
	inoremap ' ''<ESC>i

	nmap <leader>ee :e $MYVIMRC<cr>
	nmap <C-n> :20Lexplore<cr>

	noremap H ^
	nnoremap L $

	inoremap jk <Esc>
	tnoremap jk <C-\><C-n>

	nmap <silent> j :bn<CR>
	nmap <silent> k :bp<CR>
	nmap <silent> q :bdelete<CR>
	nmap <silent> s :w !sudo tee "%"<CR>
	nmap <silent> <c-q> :bwipeout<CR>
	nmap <silent> <c-s> :w<CR>
	inoremap <c-f> <Right>
	inoremap <c-b> <Left>
	inoremap <c-k> <ESC>d$a
	inoremap i <ESC>I
	inoremap a <ESC>A
	inoremap f <ESC>wi
	inoremap b <ESC>bi
	inoremap e <ESC>ea

	#find prefix
	nmap <leader>ft :BTag<CR>
	nmap <leader>fT :Tags<CR>
	nmap <leader>ff :Files<CR>
	nmap <leader>fl :BLines<CR>
	nmap <leader>fL :Lines<CR>
	nmap <leader>fs :execute ":BTag " . expand('<cword>')<CR>
	nmap <leader>fS :execute ":Tags " . expand('<cword>')<CR>
	nmap <leader>fw :execute ":BLines " . expand('<cword>')<CR>
	nmap <leader>fW :execute ":Lines " . expand('<cword>')<CR>

	nmap <C-p> :Maps<CR>

	nmap ,f :Files<CR>
	nmap ,l :Lines<CR>
	nmap ,t :TaskList<CR>
	nmap ,n :NERDTreeToggle<CR>
	nmap ,d :NERDTreeFind<CR>
	nmap ,s :TagbarToggle<CR>

	# lsp prefix
	nmap <leader>lt :call <SID>ToggleLsp()<CR>
	nmap <leader>lr :LspRename<CR>
	nmap <leader>lc :LspCodeLens<CR>
	nmap <leader>lh :LspHover<CR>
	nmap gd :LspDefinition<CR>
	nmap gr :LspReferences<CR>
	nmap <C-j> :LspNextDiagnostic<CR>
	nmap <C-k> :LspPreviousDiagnostic<CR>
enddef

