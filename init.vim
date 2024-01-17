vim9script

import './basic.vim' as basic
basic.Setup()

import './std/plug_manager.vim' as plug
plug.InstallPlugVim()

import "./plugin/basic-plugin.vim" as basic_plugin 
basic_plugin.Setup()

import './config/basic-plugin-config/init.vim' as basic_plugin_config
basic_plugin_config.Setup()

import './plugin/extend-plugin.vim' as extend_plugin
extend_plugin.Setup()

import './config/extend-plugin-config/init.vim' as extend_plugin_config
extend_plugin_config.Setup()

import './event.vim' as event
event.Setup()

import './config/basic-plugin-config/builtin.vim' as builtin
builtin.Setup()

