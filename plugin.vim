vim9script

import './global.vim' as G
export def Setup()

	if !get(g:, 'lxdvim_extend_plug', false)
		return
	endif

	var plug_list: list<dict<any>> = [{
		name: 'neoclide/coc.nvim',
		option: {'branch': 'release'}
	}]
	G.PluginLoad(plug_list)
enddef

#Setup()
