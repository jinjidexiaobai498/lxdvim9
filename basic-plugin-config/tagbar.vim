vim9script
export def Setup()
	# Tagbar
	g:tagbar_autofocus = 1
	nmap ,s :TagbarToggle<CR>
enddef
