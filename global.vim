vim9script
const VIM_DATA_PATH = expand('~/.vim')
const VIM_PLUG_PATH = VIM_DATA_PATH .. "/autoload/plug.vim"

var BASIC_PLUGIN_LIST: list<any> = null_list

export def GetIsExtendInstalledPlugins(): bool
	return isdirectory(VIM_DATA_PATH .. '/plugged/coc.nvim/.git')
enddef

export def GetIsBasicInstalledPlugins(): bool
	return isdirectory(VIM_DATA_PATH .. '/plugged/nerdtree/.git')
enddef


import './builtin-plugin/std/global.vim' as utils
var debug = false

var Log = utils.GetLog(debug)

def Test()
	Log("vim_plug_path: ", VIM_PLUG_PATH)
	Log("vim_data_path: ", VIM_DATA_PATH)
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

export def PlugSet(plug: dict<any>)
	var opt = get(plug, 'option', null_dict)
	PlugAdd(plug.name, opt)
enddef

export def PlugAdd(name: string, option: dict<any> = null_dict)
	if option != null_dict
		exe 'Plug ' .. name->string() .. ',' .. option->string()
	else
		exe 'Plug ' .. name->string()
	endif
enddef

export def PlugListAdd(name: string, option: dict<any> = null_dict)
	PLUGIN_LIST->add({name: name, option: option})
enddef

export def PlugGlobalAdd(name: string, option: dict<any> = null_dict)
	PlugAdd(name, option)
	BASIC_PLUGIN_LIST->add({name: name, option: option})
enddef

export def PlugAddList(plugins: list<dict<any>>)

	var i = 0
	var len = len(plugins)

	while i < len
		Log('name: ' .. plugins[i].name->string())
		Log('option: ' .. plugins[i].option->string())
		PlugSet(plugins[i])
		i +=  1
	endwhile


enddef


export def PluginLoad(plugins: list<dict<any>>, fflag = false)

	var flag = get(g:, 'lxdvim_extend_plug', false)

	if !flag
		return
	endif

	var  is_installed_plugins = GetIsExtendInstalledPlugins()


	call plug#begin("~/.vim/plugged")

	PlugAddList(BASIC_PLUGIN_LIST)

	PlugAddList(plugins)

	call plug#end()

	var just_installed = get(g:, '__just_installed__', false)

	if just_installed || !is_installed_plugins || fflag
		echo "Installing Bundles, please ignore key map error messages"
		:PlugInstall
	endif

enddef
#Test()
