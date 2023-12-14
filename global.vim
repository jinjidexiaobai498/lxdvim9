vim9script
export const USE_NEOVIM = has('nvim')
export const USE_VIM = !USE_NEOVIM
export const VIM_DATA_PATH = USE_NEOVIM ? stdpath('data') : expand('~/.vim')
export const VIM_PLUG_PATH = USE_NEOVIM ? expand('~/.config/nvim/autoload/plug.vim') : VIM_DATA_PATH .. "/autoload/plug.vim"

export def GetIsExtendInstalledPlugins(): bool
	return isdirectory(VIM_DATA_PATH .. '/plugged/vim-lsp/.git')
enddef
export def GetIsBasicInstalledPlugins(): bool
	return isdirectory(VIM_DATA_PATH .. '/plugged/nerdtree/.git')
enddef

export var IS_EXTEND_INSTALLED_PLUGINS = GetIsExtendInstalledPlugins()
export var IS_BASIC_INSTALLED_PLUGINS  = GetIsBasicInstalledPlugins()
export var LSP_STATUS = true

export var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef


def Test()
	echom "vim_plug_path: " .. VIM_PLUG_PATH
	echom "vim_data_path: " .. VIM_DATA_PATH
enddef

export def InstallPlugVim()
	var vim_plug_path = VIM_PLUG_PATH->copy()
	Log('vim_plug_path: ' .. vim_plug_path)

	var just_installed = get(g:, '__just_installed__', false)
	
	if !filereadable(vim_plug_path)
		echom "Installing Vim-plug..."

		#silent !mkdir -p ~/.vim/autoload
		#silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		!mkdir -p ~/.vim/autoload
		!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

		g:__just_instaled__ = true
		just_installed = true
	endif


	# manually load vim-plug the first time
	if just_installed
		:execute 'source ' .. fnameescape(vim_plug_path)
	endif

	# active vim-plug
	call plug#begin("~/.vim/plugged")
	call plug#end()
	Log('just_installed: ' .. just_installed)
enddef

def PluginLoad()

	var flag = get(g:, 'lxdvim_extend_plug', false)

	if !flag
		return
	endif

	var  is_installed_plugins = g.GetIsExtendInstalledPlugins()

	call plug#begin("~/.vim/plugged")

	call plug#end()

	var just_installed = get(g:, '__just_installed__', false)
	if just_installed || !is_installed_plugins
		echo "Installing Bundles, please ignore key map error messages"
		:PlugInstall
	endif

enddef




# ctlr-p to find all features or go to file "./keymap.vim "
# some key words about features to use in search
# ------------------------------------
# terminal 
# task
# tag
# lsp
# surround
# nerdtree
# fzf
# comment


#Test()
