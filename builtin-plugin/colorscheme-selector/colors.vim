vim9script
import "../std/global.vim" as G
import "../std/file.vim" as file
const COLOR_LIST_NAME = 'colors_selected_file.vimd'
const COLOR_LIST_FILE = G.DATA_DIR .. '/' .. COLOR_LIST_NAME


export var debug = false
var Log = G.GetLog(debug)
var Assert = G.GetAssertTrue(expand('<sfile>'))

def! g:Colors_Save()
	var cname = get(g:, 'colors_name', 'default')
	ColorsList.sfile.Set(0, cname)
	ColorsList.sfile.Sync()
	Log('save colorscheme ', cname)
enddef

export def LastColorLoad()
	exe 'colorscheme ' .. ColorsList.sfile.Get(0)
enddef

export class ColorsList
	static sfile = file.File.new(COLOR_LIST_FILE)
	static searched_list: list<string> = null_list
	static colors: list<string> = null_list
	static SELECT_KEY = {s: true, '\<Space>': true}
	static EXIT_KEY = {q: true, x: true, ESC: true}

	def new()
		InSync()
	enddef

	static def GetList(): list<string>
		InSync()
		return colors->copy()
	enddef

	static def InSync()

		if searched_list == null_list || empty(searched_list)
			searched_list = globpath(&rtp, ['colors', '*.vim']->join(G.Backslash))->split('\n')
		endif

		Log('at New() searched list : ' .. searched_list->string())

		if colors != null_list || !empty(colors)
			Log('at New() colors : ' .. colors->string())
			return
		endif

		var j = 0
		var SIZE = len(searched_list)
		colors = ['####colors####']
		while j < SIZE
			var i = searched_list[j]->copy()
			Log('i: ' .. i)

			var start = i->strridx(G.Backslash) + 1
			Log('start: ' .. start)
			var end = i->strridx('.') - 1
			Log('end: ' .. end)
			colors->add(i[start : end]->copy())
			j += 1
		endwhile
		Log('at New() colors : ' .. colors->string())

	enddef
	static def ColorConfig()
		if !get(g:, 'ColorsList_Config', false)
			return
		endif
		#设置透明背景
		Log('ColorConfig')
		highlight Normal ctermbg=none
		highlight NonText ctermbg=none
	enddef

	static def CallBack(id: number, result: any)
		if result > 1
			exec "colorscheme " .. colors[result - 1]
			ColorConfig()
		endif 
	enddef

	static def Filter(winid: number, key: string): bool
		if SELECT_KEY->has_key(key)
			win_execute(winid, '@t = getline(".")')
			exe 'colorscheme ' .. @t
		elseif EXIT_KEY->has_key(key)
			popup_close(winid, 0)
		else
			popup_filter_menu(winid, key)
		endif
		return true
	enddef

	def PopupMenu()
		var winid = popup_menu(colors, {
			callback: CallBack,
			filter: Filter
		})

		var cname = get(g:, 'colors_name', 'default')

		var idx = colors->index(cname)
		Assert(idx != -1, 'cannot find the color you use', cname)

		win_execute(winid, 'setlocal cursorline')
		win_execute(winid, 'normal ' .. idx .. 'j')
	enddef
endclass

def Sync(cl: ColorsList)
	cl.InSync()
enddef

export def Setup()
	g:_colors_list_ = ColorsList.new()
	nmap <Plug>ColorsPopupBrowser :call <SID>PopupBrowser(g:_colors_list_)<CR>
	nmap <Plug>ColosSync :call <SID>Sync(g:_colors_list_)<CR>
	#LastColorLoad()
	augroup ColorsSelectedSave
		au!
		autocmd VimLeave * call g:Colors_Save()
	augroup END
	LastColorLoad()
enddef

export def PopupBrowser(cl: ColorsList)
	cl.PopupMenu()
enddef

def TestPop()
	#g:_colors_list_ = ColorsList.new()
	#nmap ,c :call <SID>PopupBrowser(g:_colors_list_)<CR>
	var t = ColorsList.new()
	t.PopupMenu()
enddef

#TestPop()
#Test2()
#Test4()
