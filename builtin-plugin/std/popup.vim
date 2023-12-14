vim9script

export class Popup

endclass

class PopupOption
	public this.pos = 'center'
	public this.col = '0'
	public this.line = '0'
	public this.callback = 'popup_filter_menu'
	public this.content = null_list
	def new(this.content)

	enddef

	def GetDict(): list<string>
		return this->copy()
	enddef

	def Print()
		echom this->string()
	enddef

endclass

def Test()
	var p = PopupOption.new(['yes', 'no'])
	p.Print()
enddef

def Default_Normal_filter(winid: number, key: string): bool

	if win_getid() != winid
		win_gotoid(winid)
	endif

	if key == '<Space>'
		popup_close(winid, getline('.'))
		return true
	endif


	if key == 'q'
		popup_close(winid, 0) 
		return true
	endif

	return popup_filter_menu(winid, key)
enddef

def Default_Popup_Callback(id: number, result: any)
	echom 'result: ' .. result->string()
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

def Test3()
	var L = GetLog(true)
	L('hello world', 'lxd')
enddef

def Test3()
	hi link Terminal Search
	var buf = term_start('/bin/bash', {hidden: 1, term_finish: 'close'})
	var winid = popup_create(buf, {minwidth: 50, minheight: 20})

enddef

def Test()
	var bufnr = bufadd('test')
	bufload(bufnr)
	setbufline(bufnr, 1, ['test'])
	var winid = popup_create(bufnr, {minwidth: 50, minheight: 20})
enddef

Test()
#TestDefault()
#Teso()
Test3()
#CloseNerdTree()

