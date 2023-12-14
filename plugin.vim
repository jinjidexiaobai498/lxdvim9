vim9script

import './global.vim' as G
import './config/init.vim' as plugin
export def Setup()
	var plug_list: list<dict<any>> = [{
		name: 'neoclide/coc.nvim',
		option: {'branch': 'release'}
	}]
	G.PluginLoad(plug_list)
	plugin.Setup()
enddef

#Setup()
