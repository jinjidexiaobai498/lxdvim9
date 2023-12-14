vim9script

&encoding = 'utf-8'
import './global.vim' as G

#install plug.vim 
G.InstallPlugVim()

import './basic.vim' as basic
import "./basic-plugin.vim" as basic_plugin 
import './event.vim' as event

export def Setup()
	basic.Setup()
	basic_plugin.Setup()
	event.Setup()
enddef

Setup()

