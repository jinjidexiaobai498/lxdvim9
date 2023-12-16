vim9script

&encoding = 'utf-8'
import './global.vim' as G

#install plug.vim 
G.InstallPlugVim()

import './basic.vim' as basic
basic.Setup()

import "./basic-plugin.vim" as basic_plugin 
basic_plugin.Setup()

import './plugin.vim' as plugin
plugin.Setup()

import './event.vim' as event
event.Setup()

import './basic-plugin-config/builtin.vim' as builtin
builtin.Setup()

