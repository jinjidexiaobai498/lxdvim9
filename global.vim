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

def Test()
	echom "vim_plug_path: " .. VIM_PLUG_PATH
	echom "vim_data_path: " .. VIM_DATA_PATH
enddef

#Test()
