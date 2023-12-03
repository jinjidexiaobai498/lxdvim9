vim9script
&encoding = 'utf-8'
import "./plugin.vim" as plugin
import "./basic.vim" as basic
import "./keymap.vim" as keymap
basic.BasicOptionConfig()
plugin.PlugLoad(plugin.InstallPlugVim())
plugin.BasicPluginConfig()
keymap.UsefulKeymapLoad()
import "./plugin/terminal-help/setup.vim" as term
term.Setup()

