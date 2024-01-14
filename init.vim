vim9script

&encoding = 'utf-8'
import './global.vim' as G

G.InstallPlugVim()

import './basic.vim' as basic
basic.Setup()

import "./basic-plugin.vim" as basic_plugin 
basic_plugin.Setup()

import './basic-plugin-config/init.vim' as basic_config
basic_config.Setup()

import './plugin.vim' as plugin
plugin.Setup()

import './config/init.vim' as config
config.Setup()

import './event.vim' as event
event.Setup()

import './basic-plugin-config/builtin.vim' as builtin
builtin.Setup()

