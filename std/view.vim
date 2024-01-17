vim9script

import './global.vim' as G
const __FILE__ = expand('<sfile>')
var debug = false
var Log = G.GetLog(debug, __FILE__)
var Info = G.GetLog(true)
var AssertTrue = G.GetAssertTrue(expand('<sfile>:p'))

export class SimpleToggleView
	this.bufnr: number = -1
	this.WindowLayoutOpen: func
	this.WindowLayoutHidden: func

	static def DefaultSimpleToggleWindowLayoutOpen()
		exe ":20 Sexplore!"
	enddef

	def new(WinOpen: func = null_function, WinHidden: func = null_function)
		this.WindowLayoutOpen = G.OR(WinOpen,  DefaultSimpleToggleWindowLayoutOpen)
		this.WindowLayoutHidden = G.OR(WinHidden, SafeCloseWindow)
	enddef

	def Open()
		this.WindowLayoutOpen()
		this.bufnr = bufnr()
	enddef

	def Toggle()
		ToggleBufferView(this.bufnr, this.Open, this.WindowLayoutHidden)
	enddef


endclass

export class View
	this.bufnr: number
	this.WindowLayoutOpen: func
	this.WindowLayoutHidden: func

	static def BasicDefaultWindowLayoutOpen()
	enddef

	static def BasicDefaultWindowLayoutHidden()
		exec 'b ' .. expand('#')
	enddef


	def new(bufnr: number = -1, WinOpen: func = null_function, WinHidden: func = null_function)
		this.bufnr = bufnr
		this.WindowLayoutOpen = G.OR(WinOpen, BasicDefaultWindowLayoutOpen)
		this.WindowLayoutHidden = G.OR(WinHidden, BasicDefaultWindowLayoutHidden)
	enddef

	def GetIsView(): bool 
		return IsView(this.bufnr)
	enddef

	def SetBufnr(bufnr: number)
		this.bufnr = bufnr
	enddef

	def Toggle()
		AssertTrue(BufExists(this.bufnr),  'bufnr doesnot exist or unloaded, bufnr:', this.bufnr)
		ToggleBufferView(this.bufnr, this.Open, this.Close)
	enddef

	def Close()
		this.WindowLayoutHidden()
	enddef

	def Open()
		this.WindowLayoutOpen()
		exe 'b ' .. this.bufnr
	enddef

endclass

export def SafeCloseWindow()
	try
		close
	catch /^Vim\%((\a\+)\)\=:E444:/
		exe 'vs'
		var winnr = winnr() + 1
		exe 'e 1'
		exe winnr .. 'close'
	endtry
enddef

export def ConfigLocalHiddenToggleBuffer()
	setlocal nonumber norelativenumber signcolumn=no
	setlocal bufhidden=hide
	setlocal nobuflisted
enddef

export def BufExists(bufnr: number): bool
	return (bufexists(bufnr) && !empty(bufname(bufnr)))
enddef

export def IsView(bufnr: number): bool
	return bufwinnr(bufnr) >= 0
enddef

export def ClearBufferWindow(bufnr: number)
	if !BufExists(bufnr)
		return
	endif

	if IsView(bufnr)
		SafeCloseWindow()
	endif

	exe 'bdelete ' .. bufnr
enddef

export def ToggleBufferView(bufnr: number, WinOpen: func, WinHidden: func)
	var wnr = bufwinnr(bufnr)
	if wnr >= 0
		Log('this.winnr:', wnr)
		var _cwinid = win_getid()
		var _winid = win_getid(wnr)
		if _winid != _cwinid
			win_gotoid(_winid)
		endif
		WinHidden()
		if _cwinid != win_getid()
			win_gotoid(_cwinid)
		endif
	else
		WinOpen()
	endif

enddef

export def CheckBuffer(bufnr: number)
	AssertTrue(BufExists(bufnr),  'bufnr doesnot exist or unloaded, bufnr:', bufnr)
enddef

def Test()
	var v = View.new(1)
	#var v = SimpleToggleView.new()
	g:ITest = () => v.Toggle()
	nmap <leader>tt :call g:ITest()<CR>
enddef
#Test()
