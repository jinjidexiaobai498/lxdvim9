vim9script
export def Setup()
	nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
	nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
enddef
#echom 'whick-key'
