vim9script
const BasicPluginsList 	= [
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

const ExtendPluginsList = [
    {name: 'neoclide/coc.nvim', option: {branch: 'release'}}
]

const VIM_PLUG_PATH	    = expand('~/.vim/autoload/plug.vim')
const VIM_PLUG_DIR	    = expand('~/.vim/plugged')
const BASIC_PLUGIN_DIR	= expand('~/.vim/plugged/nerdtree/.git')
const EXTEND_PLUGIN_DIR	= expand('~/.vim/plugged/coc.nvim/.git')
const IsWindows         = has("win32") || has("win64")
var just_installed  = false
if !filereadable(VIM_PLUG_PATH)
	echo "Installing Vim-plug..."
	exe $'!mkdir {IsWindows ? "" : "-p"} {expand("~/.vim/autoload")}'
	exe $'!curl -fLo {VIM_PLUG_PATH} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	just_installed = true
endif

def PlugAddList(plugins: list<dict<any>>)
    for plugin in plugins
        exe $"Plug {(!plugin->has_key('option') ? string(plugin.name) : $'{string(plugin.name)},{string(plugin.option)}')}"
    endfor
enddef

if IsWindows | exe $'so {VIM_PLUG_PATH}' | endif
plug#begin(VIM_PLUG_DIR)
PlugAddList(BasicPluginsList)
if get(g:, 'lxdvim_extend_plug', true)| PlugAddList(ExtendPluginsList)| endif
plug#end()

if just_installed || !isdirectory(BASIC_PLUGIN_DIR) || (get(g:, 'lxdvim_extend_plug', true) && !isdirectory(EXTEND_PLUGIN_DIR))
	echo "Installing plugins"
	PlugInstall
endif
