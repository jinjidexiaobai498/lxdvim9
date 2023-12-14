vim9script
import "../std/global.vim" as G
import "../std/file.vim" as file
const COLOR_LIST_NAME = 'colors_selected_file.vimd'
const COLOR_LIST_FILE = G.DATA_DIR .. '/' .. COLOR_LIST_NAME

var cf = file.File.new(COLOR_LIST_FILE)

export var debug = false

def Log(msg: string)
	if debug
		echom msg
	endif
enddef

def! g:Colors_Save()
	cf.Set(0, g:colors_name)
	cf.Write()
	Log('save colorscheme ' .. g:colors_name)
enddef

export def LastColorLoad()
	exe 'colorscheme ' .. cf.Get(0)
enddef

export class ColorsList
	this.searched_list: list<string>
	this.colors: list<string>
	this.selected_save_file = file.File.new(COLOR_LIST_FILE)

	def new()
		this.Sync()
	
	enddef


	def PopupBrowser()

		var winid = popup_create(this.colors, {
			pos: 'center',
			zindex: 200,
			drag: false,
			wrap: 0,
			border: [],
			cursorline: true,
			padding: [0, 1, 0, 1],
			filter: 'popup_filter_menu',
			mapping: false,
			filtermode: 'n',
			callback: this.CallBack
		})

		win_execute(winid, 'setlocal cursorline')
	enddef

	def Sync()
		this.searched_list = globpath(&rtp, 'colors/*.vim')->split('\n')
		Log('at New() searched list : ' .. this.searched_list->string())
		var j = 0
		var SIZE = len(this.searched_list)
		this.colors = ['####colors####']
		while j < SIZE
			var i = this.searched_list[j]->copy()
			Log('i: ' .. i)
			var start = i->strridx('/') + 1
			Log('start: ' .. start)
			var end = i->strridx('.') - 1
			Log('end: ' .. end)
			this.colors->add(i[start : end]->copy())
			j += 1
		endwhile
		Log('at New() colors : ' .. this.colors->string())

	enddef

	def CallBack(id: number, result: any)
		if result > 1
			exec "colorscheme " .. this.colors[result - 1]
		 endif 
	enddef

	def Filter(winid: number, key: string): bool
		if !debug
			return true
		endif
		if key == 'q'
			popup_close(winid, 0)
		else
			popup_filter_menu(winid, key)
		endif
		return true
	enddef

	def PopupMenu()
		var winid = popup_menu(this.colors, {
			callback: this.CallBack
		#filter: this.Filter
		})

		win_execute(winid, 'setlocal cursorline')
	enddef
	#def PopupBrowser()
	#popup_menu(this.colors, {
	#callback: (_, result) => {
	#if result > 1
	#exec "colorscheme " .. this.colors[result - 1]
	#endif
	#},
	#filter: (id, key) => {
	#if key == 'q'
	#popup_close(id, 0)
	#else
	#popup_filter_menu(id, key)
	#endif
	#return true
	#}
	#})
	#enddef
endclass

def Sync(cl: ColorsList)
	cl.Sync()
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
	var searched_list = globpath(&rtp, 'colors/*.vim')->split('\n')
	var colors: list<string> = ['###colors###']

	Log('at New() searched list : ' .. searched_list->string())
	var j = 0 var SIZE = len(searched_list) while j < SIZE
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
	g:_colors_list_ = ColorsList.new()
	nmap ,c :call <SID>PopupBrowser(g:_colors_list_)<CR>
enddef

def Test2()
	var searched_list = globpath(&rtp, 'colors/*.vim')->split('\n')
	var colors: list<string> = ['###colors###']

	Log('at New() searched list : ' .. searched_list->string())
	var j = 0 
	var SIZE = len(searched_list)
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

	var opts = {
		pos: 'center',
		zindex: 200,
		drag: false,
		wrap: 0,
		border: [],
		cursorline: true,
		padding: [0, 1, 0, 1],
		filter: 'popup_filter_menu',
		mapping: false,
		filtermode: 'n',
		callback: (_, result) => {
			if result > 1
				exec "colorscheme " .. colors[result - 1]
			endif
		}
	}

	var winid =	popup_create(colors,  opts)
	win_execute(winid, 'setlocal cursorline')

enddef

def Test3()
	cf.Set(0, 'evening')
	echom cf.GetLines()->string()
	cf.Write()
	var af = file.File.new(COLOR_LIST_FILE)
	echom af.GetLines()->string()
enddef
def Test4()
	#do VimLeave
	#g:Colors_Save()
	var af = file.File.new(COLOR_LIST_FILE)
	echom af.GetLines()->string()
	Log(cf.Get(0))
	exe 'colorscheme ' .. cf.Get(0)
enddef
#TestPop()
#Test2()
#Test4()
