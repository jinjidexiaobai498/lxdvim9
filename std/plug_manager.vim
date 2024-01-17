vim9script
import './global.vim' as G
var debug = false
var Info = G.GetLog(true)
var Log = G.GetLog(debug)

export const VIM_PLUG_PATH			= expand('~/.vim/autoload/plug.vim')
export const VIM_PLUG_DIR			= expand('~/.vim/plugged')
export const EXTEND_PLUGIN_DIR		= expand('~/.vim/plugged/coc.nvim/.git')
export const BASIC_PLUGIN_DIR		= expand('~/.vim/plugged/fzf.vim/.git')

export var just_installed = false
export def InstallPlugVim()
	var path = expand('~/.vim/autoload')
	if !filereadable(VIM_PLUG_PATH)
		Info("Installing Vim-plug...")
		var args = G.UseWindows ? '' : '-p'
		exe $'!mkdir {args} {path}'
		exe $'!curl -fLo {VIM_PLUG_PATH} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
		just_installed = true
	endif

	if just_installed
		exe $'source {VIM_PLUG_PATH}'
	endif
	# active vim-plug
	call plug#begin(VIM_PLUG_DIR)
	call plug#end()
enddef

var BASIC_PLUGIN_LIST: list<any> = null_list
export def PlugGlobalAddList(plugins: list<dict<any>>)
	for plugin in plugins
		PlugAdd(plugin.name, get(plugin, 'option', null_dict))
		BASIC_PLUGIN_LIST->add(plugin)
	endfor
enddef

export def PluginLoad(plugins: list<dict<any>>, fflag = false)
	var is_installed_extend_plugins = isdirectory(EXTEND_PLUGIN_DIR)
	call plug#begin(VIM_PLUG_DIR)
	PlugAddList(BASIC_PLUGIN_LIST)
	PlugAddList(plugins)
	call plug#end()

	if just_installed || !is_installed_extend_plugins || fflag
		Info("Installing Bundles, please ignore key map error messages")
		:PlugInstall
		just_installed = false
	endif
enddef

def PlugAdd(name: string, option: dict<any> = null_dict)
	exe 'Plug ' .. (option == null_dict ? name->string() : name->string() .. ',' .. option->string())
enddef

def PlugAddList(plugins: list<dict<any>>)
	for plugin in plugins
		PlugAdd(plugin.name, get(plugin, 'option', null_dict))
	endfor
enddef
#Test()
