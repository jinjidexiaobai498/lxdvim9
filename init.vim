vim9script

&encoding = 'utf-8'
import './global.vim' as G
G.InstallPlugVim()

import './basic.vim' as basic
import "./plugin.vim" as plugin 
import './event.vim' as event

export def Setup()
	basic.Setup()
	plugin.Setup()
	event.Setup()
enddef

Setup()
