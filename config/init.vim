vim9script
import './coc-nvim.vim' as coc

export def Setup()
	if !get(g:, 'lxdvim_extend_plug', false)
		return
	endif
	coc.Setup()
enddef
