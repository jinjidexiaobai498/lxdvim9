vim9script

import '../../builtin-plugin/init.vim' as builtin

export def Setup()

	builtin.Setup()
	var flag = get(g:, 'use_lxdvim_default_keymap', true)

	if !flag
		return
	endif

	nmap ,p <Plug>PSLPopupBrowser
	nmap ,c <Plug>ColorsPopupBrowser
	nmap ,r <Plug>RecentFiles
	nmap ,F <Plug>FZFFunctions
	nmap ,d <Plug>NetrwToggle
	nmap ,e <Plug>NetrwToggle

	nmap <leader>sc <Plug>ColorsSync
	nmap <leader>ss <Plug>PSLSave
	nmap <leader>pp <Plug>PSLPopupBrowser
	nmap <leader>th <Plug>HortTerminalToggle
	nmap <leader>tv <Plug>VertTerminalToggle

	nmap <leader>fd <Plug>FZFFunctions

	nmap <c-g> <Plug>RefreshGitDiffMark

	nnoremap <C-/> <Plug>VertTerminalToggle
	tnoremap <C-/> <Plug>VertTerminalToggle

	nnoremap <C-\> <Plug>HortTerminalToggle
	tnoremap <C-\> <Plug>HortTerminalToggle

	nnoremap <C-l> <Plug>HortTerminalCwdToggle 
	tnoremap <C-l> <Plug>HortTerminalCwdToggle 

	if executable('lazygit')
		nmap ,g :call <SID>Lazygit()<CR>
	endif
enddef

export def Lazygit()
	exe 'lcd ' .. expand('%:h')
	exe '!lazygit'
enddef

#Lazygit()
