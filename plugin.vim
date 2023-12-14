vim9script
&encoding = 'utf-8'
import "./global.vim" as g

var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export def PluginLoad()
	var  is_installed_plugins = g.GetIsExtendInstalledPlugins()

	call plug#begin("~/.vim/plugged")

	call plug#end()

	var just_installed = get(g:, '__just_installed__', false)
	if just_installed || !is_installed_plugins
		echo "Installing Bundles, please ignore key map error messages"
		:PlugInstall
	endif

enddef

def BasicPluginLoad()
	#execute 'source ' .. fnameescape(g.VIM_PLUG_PATH)->copy()

	call plug#begin("~/.vim/plugged")

	# Code and files fuzzy finder
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
	Plug 'junegunn/fzf.vim'

	Plug 'scrooloose/nerdtree'

	# Class/module browser
	Plug 'majutsushi/tagbar'

	Plug 'fisadev/FixedTaskList.vim'
	# Surround
	Plug 'tpope/vim-surround'

	# Code commenter
	Plug 'scrooloose/nerdcommenter'

	# A couple of nice colorschemes
	Plug 'fisadev/fisa-vim-colorscheme'
	Plug 'patstockwell/vim-monokai-tasty'

	Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }


	call plug#end()

	var flag = g.GetIsBasicInstalledPlugins()
	var just_installed = get(g:, '__just_installed__', false)
	if !flag || just_installed
		Log("flag of BasicInstalledPlugins" .. flag)
		echom "Installing basic plugins"
		:PlugInstall
	endif
enddef

import './basic-plugin-config/init.vim' as basic_config

export def Setup()

	BasicPluginLoad()

	basic_config.Setup()

	var flag = get(g:, 'lxdvim_extend_plug', false)

	if !flag
		return
	endif

	PluginLoad()

enddef
