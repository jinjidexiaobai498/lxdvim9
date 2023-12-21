vim9script
import '../std/global.vim' as G
import '../std/view.vim' as view
import '../std/project.vim' as project
var debug = true
var Log = G.GetLog(debug)
var info = true
var Info = G.GetLog(info)
const BUF_NAME_PREFIX = '___WorkSpace___'
const INDENT_SPACE = '  '

const ItemType = {
	SingleFile: 0,
	Project: 1
}

const ProjectTypeDecode = ['SingleFile', 'Project']

class WorkSpaceItem
	public this.name
	public this.type: number
	public this.opened_file_list: list<string>

	def new(p: project.Project)
		this.name = p.name
		this.type = p.type
		this.Add(p.filename)
	enddef

	def Add(filename: string)
		if this.type == ItemType.SingleFile
			return
		endif
		this.opened_file_list->add(filename)
	enddef

endclass



class WorkSpace
	static ID = 0
	public this.map: dict<number> = {}
	public this.list: list<WorkSpaceItem> = []
	this._view: view.View
	this.bufnr: number = -1
	this.is_init = false
	this.is_config = false
	this.project_map = {}
	this.is_sync = true

	def ConfigLocalBuf()
		setlocal nonumber norelativenumber signcolumn=no
		setlocal bufhidden=hide
		setlocal nobuflisted
	enddef

	def Read(bufinfo: dict<any>)
		var bufnr = bufinfo.bufnr
		var name = bufinfo.name

		if this.map->has_key(name)
			this.map[name] = bufnr
			Log('this.map has store bufinfo.name', name)
			return
		endif

		Log('WorkSpace doesnot has this buffer:', bufinfo)
		this.map[name] = bufnr
		this.AddProject(name)

	enddef
	
	def AddProject(bufname: string)
		var p = project.Project.new(bufname)

		this.is_sync = false
		if this.project_map->has_key(p.name)
			this.project_map[p.name].Add(p.filename)
			return
		endif

		var item = WorkSpaceItem.new(p)
		this.Add(item)
	
	enddef

	def Abort(bufinfo: dict<any>)
		var name = bufinfo.name
		Log('type of this.map', type(this.map))

		if !has_key(this.map, name)
			return
		endif

		this.map->remove(name)
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

	def Add(item: WorkSpaceItem)
		this.project_map[item.name] = item
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
	Log('wk :', wk)
	Log('BufReadPostHandler')
	var bufinfo = CheckBeforeHandler(bufnr)
	if bufinfo == null_dict
		return
	endif
	wk.Read(bufinfo)
enddef

def HandlerBufDelete(bufnr: number)
	Log('BufDeleteHandler')
	var bufinfo = CheckBeforeHandler(bufnr)

	Log('bufinfo:', bufinfo)

	if !(bufinfo)
		return
	endif

	wk.Abort(bufinfo)

enddef

class DisplyBuf
	this.toplines: list<string> = []
	this.endlines: list<string> = []
	this.contents: list<string> = []
	

endclass

augroup WorkSpaceListenner
	au!
	au BufReadPost * call HandlerBufRead(expand('<abuf>')->str2nr())
	au BufDelete * call HandlerBufDelete(expand('<abuf>')->str2nr())
	au BufWipeout * call HandlerBufDelete(expand('<abuf>')->str2nr())
	# for test easy
	#au BufUnload * call HandlerBufDelete()
augroup END

g:WInfo = funcref(Info, [wk])
