vim9script
export def Setup()

	#find  in current buffer 
	nmap <leader>fl :Lines<CR> 
	nmap <leader>ft :BTag<CR>

	#find in  work direcotry
	nmap <leader>fc :Colors<CR>
	nmap <leader>fb :Buffers<CR>
	nmap <leader>fT :Tags<CR>
	nmap <leader>ff :Files<CR> 

	if executable('rg')
		nmap <leader>fL :RG<CR>
	endif

	# find by word under current cursor 
	nmap <leader>fs :execute ":BTag " . expand('<cword>')<CR>
	nmap <leader>fS :execute ":Tags " . expand('<cword>')<CR>
	nmap <leader>fw :execute ":BLines " . expand('<cword>')<CR>
	nmap <leader>fW :execute ":Lines " . expand('<cword>')<CR>

	nmap <C-p> :Maps<CR>

	nmap ,f :Files<CR>
	nmap ,l :Lines<CR>
	nmap ,b :Buffers<CR>
	nmap ,r :History<CR>

	if executable('rg')
		nmap ,L :RG<CR>
	endif

enddef
