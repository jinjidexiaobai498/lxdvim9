vim9script

import '../builtin-plugin/init.vim' as builtin

export def Setup()

	builtin.Setup()
	var flag = get(g:, 'use_lxdvim_default_keymap', true)

	if !flag
		return
	endif

	g:ColorsList_Config = true

	nmap ,p <Plug>PSLPopupBrowser
	nmap ,c <Plug>ColorsPopupBrowser
	nmap ,r <Plug>RecentFiles

	nmap <leader>sc <Plug>ColorsSync
	nmap <leader>ss <Plug>PSLSave
	nmap <leader>pp <Plug>PSLPopupBrowser
	nmap <leader>th <Plug>HortTerminalToggle
	nmap <leader>tv <Plug>VertTerminalToggle


	nmap <C-\> <Plug>VertTerminalToggle
	nmap <C-l> <Plug>HortTerminalToggle
	tnoremap <C-\> <Plug>VertTerminalToggle
	tnoremap <C-l> <Plug>HortTerminalToggle

	if executable('lazygit')
		nmap ,g :call <SID>Lazygit()<CR>
	endif
enddef

export def Lazygit()
	exe 'lcd ' .. expand('%:h')
	exe '!lazygit'
enddef

#Lazygit()
