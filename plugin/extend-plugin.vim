vim9script

import '../std/plug_manager.vim' as plug
export def Setup()

	if !get(g:, 'lxdvim_extend_plug', false)
		return
	endif

	var plug_list: list<dict<any>> = [
		{ 
			name: 'neoclide/coc.nvim',
			option: {'branch': 'release'}
		},
	]
	plug.PluginLoad(plug_list)
enddef

#Setup()
