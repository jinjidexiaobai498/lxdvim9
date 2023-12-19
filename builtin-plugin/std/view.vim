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
	public this.Show: func
	#public this.Close: func
	public this.Hidden: func

	def Sync()
		if !this.is_sync
			this.winnr = bufwinnr(this.bufnr)
			this.is_view = this.winnr > 0 ? true : false
			this.is_sync = true
		endif
	enddef

	static MSG_BUF_UNLOADED = 'bufnr doesnot exist or unloaded, bufnr:'

	def new(this.bufnr)
		AssertTrue(bufexists(this.bufnr), MSG_BUF_UNLOADED, this.bufnr )
		this.name = bufname(this.bufnr)
		AssertTrue(!empty(this.name))
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
			return (bufexists(this.bufnr) && !empty(bufname(this.bufnr)))
		else
			return true
		endif
	enddef

	def DefaultShow()
		this.Sync()
		exec 'b ' .. this.bufnr
	enddef

	def DefaultHidden()
		Log('DefaultHidden')
		exec 'b ' .. expand('#')
		#this.EndLine()
	enddef

	def Toggle()
		if !this.IsExists()
			Info(MSG_BUF_UNLOADED, this.bufnr)
			this.EndLine()
			return
		endif
		this.Sync()
		if this.is_view
			Log('this.winnr:', this.winnr)
			
			var cwinid = win_getid()
			var winid = win_getid(this.winnr)
			if winid != cwinid
				win_gotoid(winid)
			endif
			if !this.Hidden
				this.DefaultHidden()
			else
				this.Hidden()
			endif
			if cwinid != win_getid()
				win_gotoid(cwinid)
			endif
		else
			if !this.Show
				this.DefaultShow()
			else
				this.Show()
			endif
		endif
		this.EndLine()
	enddef

endclass

def Test()
	var v = View.new(1)
	g:ITest = () => v.Toggle()
	nmap <leader>tt :call g:ITest()<CR>
enddef
#Test()
