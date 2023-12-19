vim9script

import '../std/global.vim' as G
import '../std/view.vim' as view
import '../std/project.vim' as project
var debug = true
var Log = G.GetLog(debug)
var info = true
var Info = G.GetLog(info)


const BUF_NAME_PREFIX = '___WorkSpace___'


class WorkSpace
	static ID = 0
	this.map: dict<number> = {}
	this.list: list<any> = []
	this._view: view.View
	this.bufnr: number = -1
	this.is_init = false
	this.is_config = false
	this.project_map = {}

	def ConfigLocalBuf()
		setlocal nonumber norelativenumber signcolumn=no
		setlocal bufhidden=hide
		#setlocal nobuflisted
	enddef

	def Clear()
		this.is_init = false
		this.is_config = false
		if bufname(this.bufnr) != ''
			if bufwinnr(this.bufnr) > 0
				view.DefaultWindowLayoutHidden()
			endif
			exe 'bdelete ' .. this.bufnr
		endif

		this.bufnr = -1
	enddef

	def CheckBufStatus()
		if !G.BufExists(this.bufnr)
			this.Clear()
		endif
	enddef

	def Init()

		this.CheckBufStatus()

		if this.is_init
			return
		endif

		ID += 1
		this.bufnr = bufadd(BUF_NAME_PREFIX .. ID)
		bufload(this.bufnr)
		this.is_init = true
		this._view = view.View.new(this.bufnr)
		this._view.WindowLayoutOpen = this.WindowLayoutOpen
		this._view.WindowLayoutHidden = view.WindowLayoutHidden
	enddef

	static def DefaultWindowLayoutOpen()
		exec 'vert :15 split'
		exe 'b ' .. this.bufnr
		if !this.is_config 
			this.ConfigLocalBuf()
		endif
	enddef

	def new(WindowLayoutOpen: func = null_function)
		this.WindowLayoutOpen = G.OR(WindowLayoutOpen, DefaultWindowLayoutOpen)
	enddef


endclass

enum ItemType
	SingleFile
	Project
endenum

class WorkSpaceItem
	public this.name
	public this.type: ItemType
	public this.opened_file_list: list<string> = []
	def new(p: project.Project)
		this.name = p.name
		if this.type == 'SingleFile'

			return
		endif
		this.opened_file_list->add(p.filename)
	enddef
	def Add(name: string)
		if this.type ==  
	enddef

endclass

var wk = WorkSpace.new()

def CheckBeforeHandler(bufnr: number): dict<any>
	var bt = getbufvar(bufnr, '&buftype')
	Log('buftype:', bt, 'bufnr:', bufnr)

	if !empty(bt)
		return null_dict
	endif

	var bufinfolist = getbufinfo(bufnr)
	if empty(bufinfolist)
		return null_dict
	endif
	
	return bufinfolist[0]
enddef

def HandlerBufRead(bufnr: number)
	Log(wk)
	Log('BufReadPostHandler')
	var bufinfo = CheckBeforeHandler(bufnr)
	if bufinfo == null_dict
		return
	endif

	if wk.map->has_key(bufinfo.name)
		wk.map[bufinfo.name] = bufinfo.bufnr
		Log('wk.map has store bufinfo.name', bufinfo.name)
		return
	endif

	wk.map[bufinfo.name] = bufinfo.bufnr

	var p = project.Project.new(bufname(bufinfo.bufnr))

	if wk.project_map->has_key(p.name)
		wk.project_map[p.name]
		return
	endif

	wk.project_map[p.name] = 1

enddef

def HandlerBufDelete(bufnr: number)
	Log('BufDeleteHandler')
	var bufinfo = CheckBeforeHandler(bufnr)
	
	Log(bufinfo)

	if !bufinfo
		return
	endif

	Log('type of wk.map', type(wk.map))
	if !has_key(wk.map, bufinfo.name)
		return
	endif

	wk.map->remove(bufinfo.name)
enddef

augroup WorkSpaceListenner
	au!
	au BufReadPost * call HandlerBufRead(expand('<abuf>')->str2nr())
	au BufDelete * call HandlerBufDelete(expand('<abuf>')->str2nr())
	au BufWipeout * call HandlerBufDelete(expand('<abuf>')->str2nr())
	# for test easy
	#au BufUnload * call HandlerBufDelete()
augroup END

g:WInfo = funcref(Info, [wk])
