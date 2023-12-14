vim9script
export def Setup()

	#find  in current buffer 
	nmap <leader>fl :BLines<CR> 
	nmap <leader>ft :BTag<CR>

	#find in  work direcotry
	nmap <leader>fc :Colors<CR>
	nmap <leader>fb :Buffers<CR>
	nmap <leader>fT :Tags<CR>
	nmap <leader>ff :Files<CR> 
	nmap <leader>fL :Lines<CR>

	# find by word under current cursor 
	nmap <leader>fs :execute ":BTag " . expand('<cword>')<CR>
	nmap <leader>fS :execute ":Tags " . expand('<cword>')<CR>
	nmap <leader>fw :execute ":BLines " . expand('<cword>')<CR>
	nmap <leader>fW :execute ":Lines " . expand('<cword>')<CR>

	nmap <C-p> :Maps<CR>

	nmap ,f :Files<CR>
	nmap ,l :Lines<CR>

enddef
