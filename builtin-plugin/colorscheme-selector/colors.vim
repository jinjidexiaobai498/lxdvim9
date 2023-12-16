vim9script
import "../std/global.vim" as G
import "../std/file.vim" as file
const COLOR_LIST_NAME = 'colors_selected_file.vimd'
const COLOR_LIST_FILE = G.DATA_DIR .. '/' .. COLOR_LIST_NAME


export var debug = false
var Log = G.GetLog(debug)

def! g:Colors_Save()
	ColorsList.sfile.Set(0, g:colors_name)
	ColorsList.sfile.Sync()
	Log('save colorscheme ' .. g:colors_name)
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


	def PopupBrowser()

		var winid = popup_create(colors, {
			pos: 'center',
			zindex: 200,
			drag: false,
			wrap: 0,
			border: [],
			cursorline: true,
			padding: [0, 1, 0, 1],
			filter: Filter,
			mapping: false,
			filtermode: 'n',
			callback: CallBack
		})

		win_execute(winid, 'setlocal cursorline')
	enddef

	static def GetList(): list<string>
		InSync()
		return colors->copy()
	enddef

	static def InSync()

		if searched_list == null_list
			searched_list = globpath(&rtp, 'colors/*.vim')->split('\n')
		endif

		Log('at New() searched list : ' .. searched_list->string())

		if colors != null_list
			Log('at New() colors : ' .. colors->string())
			return
		endif

		var j = 0
		var SIZE = len(searched_list)
		colors = ['####colors####']
		while j < SIZE
			var i = searched_list[j]->copy()
			Log('i: ' .. i)
			var start = i->strridx('/') + 1
			Log('start: ' .. start)
			var end = i->strridx('.') - 1
			Log('end: ' .. end)
			colors->add(i[start : end]->copy())
			j += 1
		endwhile
		Log('at New() colors : ' .. colors->string())

	enddef

	static def CallBack(id: number, result: any)
		if result > 1
			exec "colorscheme " .. colors[result - 1]
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

		win_execute(winid, 'setlocal cursorline')
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
	cl.PopupBrowser()
enddef


def TestAll()
	var colors = ColorsList.GetList()
	popup_menu(colors, {
		callback: (_, result) => {
			if result > 1
				exec "colorscheme " .. colors[result - 1]
			endif
		},
		filter: (id, key) => {
			if key == 'q'
				popup_close(id, 0)
			else
				popup_filter_menu(id, key)
			endif
			return true
		}
	})

enddef

def TestPop()
	#g:_colors_list_ = ColorsList.new()
	#nmap ,c :call <SID>PopupBrowser(g:_colors_list_)<CR>
	var t = ColorsList.new()
	t.PopupMenu()
enddef

var cf = file.File.new(COLOR_LIST_FILE)

def Test3()
	cf.Set(0, 'evening')
	echom cf.GetLines()->string()
	cf.Write()
	var af = file.File.new(COLOR_LIST_FILE)
	echom af.GetLines()->string()
enddef

#TestPop()
#Test2()
#Test4()
