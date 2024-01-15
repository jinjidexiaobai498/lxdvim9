vim9script
import "../std/global.vim" as G
import "../std/file.vim" as file
const COLOR_LIST_NAME = 'colors_selected_file.vimd'
const COLOR_LIST_FILE = [G.DATA_DIR, COLOR_LIST_NAME]->join(G.Backslash)

const COLOR_SEARCH_PATH_PREFIX = ['colors', '*.vim']->join(G.Backslash)
const HELP_TEXT = ["Press '<ESC>' or '<Space>' or '<Enter>' to leave this help text", "", "Keymap Grid", "'<F1>' \t\t\t\t: help info", "'s' or '<Space>' \t\t: Load selected color but not exit", "'q' or 'x' or '<ESC>' \t\t: exit and not load", "'<Enter>' \t\t\t: load selected and exit", " 'j' or 'k' \t\t\t: move the cursor"]
const SELECT_KEY = {s: true, "\<Space>": true}
const EXIT_KEY = {q: true, x: true, ESC: true}

export var debug = false
var Log = G.GetLog(debug)
var Assert = G.GetAssertTrue(expand('<sfile>'))

export class ColorsList
	static sfile = file.File.new(COLOR_LIST_FILE)
	static searched_list: list<string> = null_list
	static colors: list<string> = null_list

	static def GetList(): list<string>
		InSync()
		return colors->copy()
	enddef

	static def InSync()
		if !empty(searched_list) && !empty(colors)
			return
		endif

		searched_list = globpath(&rtp, COLOR_SEARCH_PATH_PREFIX, false, true)
		colors = ['####colors#### ', 'press <F1> to show help file', ""]
		for color_full_path in searched_list
			var color = color_full_path[color_full_path->strridx(G.Backslash) + 1 : color_full_path->strridx('.') - 1]
			colors->add(color)
		endfor

		Log('Sync ColorsList.colors : ', colors)
		Log('Sync ColorsList.searched list : ', searched_list)
	enddef

	static def CallBack(id: number, result: any)
		if result > 3
			exec "colorscheme " .. colors[result - 1]
		endif 
	enddef

	static def Filter(winid: number, key: string): bool
		win_execute(winid, '@l = line(".")')
		if SELECT_KEY->has_key(key) &&  @l->str2nr() > 3
			win_execute(winid, '@t = getline(".")')
			exe 'colorscheme ' .. @t
		elseif EXIT_KEY->has_key(key)
			popup_close(winid, 0)
		elseif key == "\<F1>"
			popup_menu(HELP_TEXT, {
				CallBack: (i, k) => 1,
				zindex: 201
			})
		else
			popup_filter_menu(winid, key)
		endif
		return true
	enddef

	static def PopupMenu()
		InSync()
		var winid = popup_menu(colors, {
			callback: CallBack,
			filter: Filter
		})
		win_execute(winid, 'setlocal cursorline')
		win_execute(winid, 'normal ' .. colors->index(get(g:, 'colors_name', 'default')) .. 'j')
	enddef
endclass

def ColorsSave()
	ColorsList.sfile.Set(0, get(g:, 'colors_name', 'default'))
	ColorsList.sfile.Sync()
enddef

var RunColorMenu = () => ColorsList.PopupMenu()

export def Setup()
	nmap <Plug>ColorsPopupBrowser :call <SID>RunColorMenu()<CR>

	augroup ColorsSelectedSave
		au!
		autocmd VimLeave * exe 'call ' .. expand('<SID>') .. 'ColorsSave()'
	augroup END

	Log('Load colorscheme which last session use and saved int ColorsList.sfile')
	exe 'colorscheme ' .. ColorsList.sfile.Get(0)
enddef

def Test()
	Setup()
	nmap <leader>tt <Plug>ColorsPopupBrowser
enddef
#Test()
