vim9script
&encoding = 'utf-8'
import "../std/plug_manager.vim" as plug
import '../std/global.vim' as G

const BasicPluginsList = [
	{name: 'junegunn/fzf', option: {'dir': '~/.fzf', 'do': './install --all'}},
	{name: 'junegunn/fzf.vim'},
	{name: 'scrooloose/nerdtree'},
	{name: 'majutsushi/tagbar'},
	{name: 'fisadev/FixedTaskList.vim'},
	{name: 'tpope/vim-surround'},
	{name: 'scrooloose/nerdcommenter'},
	{name: 'liuchengxu/vim-which-key'},
	{name: 'fisadev/fisa-vim-colorscheme'},
	{name: 'patstockwell/vim-monokai-tasty'},
]

export def Setup()
	call plug#begin(plug.VIM_PLUG_DIR)
	plug.PlugGlobalAddList(BasicPluginsList)
	call plug#end()

	if !isdirectory(plug.BASIC_PLUGIN_DIR) || plug.just_installed
		echo "Installing basic plugins"
		:PlugInstall
	endif
enddef
