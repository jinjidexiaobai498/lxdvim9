vim9script
&encoding = 'utf-8'
import "./global.vim" as G

var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export def BasicPluginLoad()

	#var basc_plugins =
	call plug#begin("~/.vim/plugged")

	# Code and files fuzzy finder
	G.PlugGlobalAdd('junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }) 
	G.PlugGlobalAdd('junegunn/fzf.vim') 

	G.PlugGlobalAdd('scrooloose/nerdtree') 

	# Class/module browser
	G.PlugGlobalAdd('majutsushi/tagbar') 

	G.PlugGlobalAdd('fisadev/FixedTaskList.vim') 
	# Surround
	G.PlugGlobalAdd('tpope/vim-surround') 

	# Code commenter
	G.PlugGlobalAdd('scrooloose/nerdcommenter') 

	# A couple of nice colorschemes
	G.PlugGlobalAdd('fisadev/fisa-vim-colorscheme') 
	G.PlugGlobalAdd('patstockwell/vim-monokai-tasty') 

	G.PlugGlobalAdd('liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }) 


	call plug#end()

	var flag = G.GetIsBasicInstalledPlugins()
	var just_installed = get(g:, '__just_installed__', false)
	if !flag || just_installed
		Log("flag of BasicInstalledPlugins" .. flag)
		echom "Installing basic plugins"
		:PlugInstall
	endif
enddef

export def Setup()
	BasicPluginLoad()
enddef
