vim9script
export def Setup()
	highlight! link NERDTreeFlags NERDTreeDir
	g:NERDTreeDirArrowExpandable = "\u00a0"
	g:NERDTreeDirArrowCollapsible = "\u00a0"
	g:NERDTreeNodeDelimiter = "\x07"
	nmap ,n :NERDTreeFind<CR>
	nmap ,d :NERDTreeFind<CR>
	nmap <C-n> :NERDTreeToggle<CR>
enddef
