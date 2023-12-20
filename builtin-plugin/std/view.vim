vim9script
import './global.vim' as G

const __FILE__ = expand('<sfile>')
var debug = false
var Log = G.GetLog(debug, __FILE__)
var info = true
var Info = G.GetLog(info)

var AssertTrue = G.GetAssertTrue(expand('<sfile>:p'))

export class View
	this.bufnr: number
	this.winnr: number
	this.name: string
	this.is_view: bool = false
	this.is_check: bool = false
	this.is_sync: bool = false
	public this.WindowLayoutOpen: func
	public this.WindowLayoutHidden: func

	def Sync()
		if !this.is_sync
			this.winnr = bufwinnr(this.bufnr)
			this.is_view = (this.winnr > 0)
			this.is_sync = true
		endif
	enddef

	static MSG_BUF_UNLOADED = 'bufnr doesnot exist or unloaded, bufnr:'

	def new(bufnr: number = -1)
		this.bufnr = bufnr
		this.WindowLayoutOpen = G.OR(this.WindowLayoutOpen, this.DefaultWindowLayoutOpen)
		this.WindowLayoutHidden = G.OR(this.WindowLayoutHidden, BasicDefaultWindowLayoutHidden)
	enddef

	def SetBufnr(bufnr: number)
		this.bufnr = bufnr
	enddef

	def EndLine()
		this.is_check = false
		this.is_sync = false
	enddef

	def CheckBuf()
		if !this.is_check
			this.is_check = true
			AssertTrue(bufexists(this.bufnr) && !empty(this.name), MSG_BUF_UNLOADED, this.bufnr)
		endif
	enddef

	def IsExists(): bool
		if !this.is_check
			this.is_check = true
			return BufExists(this.bufnr)
		else
			return true
		endif
	enddef

	def DefaultWindowLayoutOpen()
	enddef

	static def BasicDefaultWindowLayoutHidden()
		Log('DefaultWindowLayoutHidden')
		exec 'b ' .. expand('#')
	enddef

	def ExposeCall(Fn: func)
		defer this.EndLine()
		if !this.IsExists()
			Info(MSG_BUF_UNLOADED, this.bufnr)
			return
		endif
		this.Sync()
		Fn()
	enddef

	def Toggle()
		this.ExposeCall(this.InnerToggle)
	enddef

	def InnerToggle()
		if this.is_view
			Log('this.winnr:', this.winnr)

			var _cwinid = win_getid()
			var _winid = win_getid(this.winnr)

			if _winid != _cwinid
				win_gotoid(_winid)
			endif
			this.WindowLayoutHidden()
			if _cwinid != win_getid()
				win_gotoid(_cwinid)
			endif
		else
			this.WindowLayoutOpen()
			exe 'b ' .. this.bufnr
		endif

	enddef


endclass

export def DefaultWindowLayoutHidden()
	try
		close
	catch /^Vim\%((\a\+)\)\=:E444:/
		exe 'vs'
		var winnr = winnr() + 1
		exe 'e 1'
		exe winnr .. 'close'
	endtry
enddef

export def BufExists(bufnr: number): bool
	return (bufexists(bufnr) && !empty(bufname(bufnr)))
enddef

def Test()
	var v = View.new(1)
	g:ITest = () => v.Toggle()
	nmap <leader>tt :call g:ITest()<CR>

enddef
def Test2()
	echom G.OR(null_function, 'string')
	echom !v:none
enddef
#Test2()
