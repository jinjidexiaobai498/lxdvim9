vim9script
export const DATA_DIR = expand("~/.vim")
export const HOME_CONFIG_DIR = expand("~/.config")

# the return value of getftype() which is builtin function
export const NORMAL_FILE = 'file'
export const DIRECTORY = 'dir'
export const SYMBOLIC_LINK = 'link'
export const BLOCK_DEVICE = 'bdev'
export const CHARACTER_DEVICE = 'cdev'
export const SOCKET = 'socket'
export const FIFO = 'fifo'
export const ALL_OTHER = 'other'

export var debug = true

def Info(...msgs: list<string>)
	var s = ''
	for i in msgs
		s ..= i
	endfor
	echom s
enddef

def Log(...msgs: list<any>)
	if debug
		return
	endif
	var s = ''
	for i in msgs
		s ..= i->string()
	endfor
	echom s
enddef

export class Popup

endclass

class PopupOption
	public this.pos = 'center'
	public this.col = '0'
	public this.line = '0'
	#public this.callback = funcref('popup_filter_menu')
	public this.content = null_list
	def new(this.content)
	enddef
	def GetDict(): list<string>
		var opt = {}
		opt.pot = this.pos
		opt.col = this.col
		opt.line = this.line
		opt.callback = this.callback
		return opt
	enddef
	def Print()
		echom this->string()
	enddef

endclass

def Test()
	var p = PopupOption.new(['yes', 'no'])
	p.Print()
enddef

def Default_Normal_filter(winid: number, key: string): number
	if winid != winnr()
		win_gotoid(winid)
	endif
	if key == '<Space>'
		popup_close(winid, getline('.'))
		return 1
	endif


	if key == 'q'
		popup_close(winid, getline('.'))
		return 1
	endif

	return 0
enddef
def Default_Popup_Callback(id: number, result: string)
	echom 'result: ' .. result
enddef

def Default_PopUp(content: list<string>)
	var opt = {}
	opt.maxwidth = 100
	opt.minwidth = 30
	opt.maxheight = 100
	opt.minheight = 30
	opt.hidden = false
	opt.tabpage = -1
	opt.title = 'view'
	opt.wrap = true
	opt.drag = true
	opt.close = 'button'
	opt.padding = [1, 1, 1, 1]
	opt.border = [1, 1, 1, 1]
	opt.scroller = true
	opt.zindex = 200
	#opt.moved = [0, 0, 0]
	#opt.mousemoved = [0, 0, 0]
	opt.cursorline = true
	opt.mapping = false
	opt.filtermode = 'n'
	opt.callback = Default_Popup_Callback
	opt.filter = Default_Normal_filter
	popup_create(content, opt)

enddef

def TestDefault()
	popup_menu(['111', '222', '3333'], {
		callback: (_, result) => {
			echom 'dialog ' .. result
		},
		filter: (id, key) => {
			return popup_filter_menu(id, key)
		}
	})

enddef
def Test2()
	Default_PopUp(['111', '222', '333'])
enddef
#TestDefault()
#Test()
#Test2()
