vim9script
import '../../std/global.vim' as G
import '../../std/view.vim' as view
import '../../std/project.vim' as project

const __FILE__ = expand('<sfile>')
var debug = true
var Info = G.GetLog(true)
var Log = G.GetLog(debug, __FILE__)
var AssertTrue = G.GetAssertTrue(__FILE__)

const BUF_NAME_PREFIX = '___WorkSpace___'
const INDENT_SPACE = '  '
const ItemType = {
	SingleFile: 0,
	Project: 1
}
const ProjectTypeDecode = ['SingleFile', 'Project']
const TAB = G.TAB
const WorkSpaceBufName = "WORSPACE_BUFFER"

export class WorkSpace
	static content: list<string> = ['WorkSpace Brower', '']
	static projetc_map: dict<any> = {}
	static buflist: list<number> = []
	static file_list: list<string> = []
	static is_sync = false
	static is_init = false
	static ID = 1

	static def Render()
		if is_sync || !is_init
			return
		endif

		#if this._view.GetIsView()
		#win_execute(winnr(), 'normal dG')
		exe 'normal dG'
		#endif

		for bufnr in buflist
			var pdict = project.GetProjectRootProto(bufname(bufnr))
			var iname = pdict.filename->slice(pdict.project_path->len() + 1)
			if projetc_map->has_key(pdict.project_path) && projetc_map[pdict.project_path]->index(iname) == -1
				projetc_map[pdict.project_path]->add(iname)
				file_list->add(pdict.filename)
			endif
		endfor

		var i = 0
		for [path, flist] in projetc_map->items()
			i += 1
			setline(i, path)
			for fl in flist
				i += 1
				setline(i, TAB .. fl)
			endfor
		endfor

	enddef


	this._view: view.View
	this.bufnr = -1
	def new(WinOpen: func = null_function, WinHidden: func = null_function)
		this._view = view.View.new(-1, WinOpen, WinHidden)
	enddef

	def Init()
		if is_init
			return
		endif
		ID += 1
		this.bufnr = bufadd(WORSPACE_BUFFER .. ID)
		this._view.SetBufnr(this.bufnr)
		this._view.WindowLayoutOpen()
		var winnr = winnr()
		view.ConfigLocalHiddenToggleBuffer()
	enddef

	def Open()
		this._view.WindowLayoutOpen()
		exe "b " .. this.bufnr
		this.Render()
	enddef

	def Close()
		this._view.WindowLayoutHidden()
	enddef

endclass
def DefaultWorkSpaceWinlayoutOpen()
	exe ':30 vsplit'
enddef

def CheckBufferNormalFile(bufnr: number): bool
	return (empty(getbufvar(bufnr, "&bt")))
enddef

def HandlerBufRead(bufnr: number)
	if ! CheckBufferNormalFile(bufnr) || WorkSpace.buflist->index(bufnr) != -1
		return
	endif

	WorkSpace.buflist->add(bufnr)
	WorkSpace.is_sync = false
enddef

def HandlerBufDelete(bufnr: number)
	if ! CheckBufferNormalFile(bufnr)
		return
	endif

	var idx = WorkSpace.buflist->index(bufnr)
	if idx == -1
		return
	endif

	WorkSpace.is_sync = false
	WorkSpace.buflist->remove(idx)
enddef

export def Setup()
	augroup WorkSpaceListenner
		au!
		au BufReadPost * call HandlerBufRead(expand('<abuf>')->str2nr())
		au BufDelete * call HandlerBufDelete(expand('<abuf>')->str2nr())
		au BufWipeout * call HandlerBufDelete(expand('<abuf>')->str2nr())
	augroup END
enddef

g:WInfo = funcref(Info, [wk])
