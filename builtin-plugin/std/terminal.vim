vim9script

import './global.vim' as G
import './view.vim' as view

const __FILE__ = expand('<sfile>')

var Assert = G.GetAssertTrue(__FILE__)
var debug = true
var Log = G.GetLog(debug, __FILE__)

export class Terminal

	public this.options = {curwin: 1, norestore: 1, term_finish: 'open', term_kill: 'kill', exit_cb: this.JobEndCallback} 
	this.name: string
	this._job: job
	this.bufnr: number = -1
	this.shell: string
	this.is_init = false
	this._view: view.View
	this.WindowLayoutOpen: func
	this.WindowLayoutHidden: func

	static def ConfigLocalTerminal()
		setlocal nonumber norelativenumber signcolumn=no
		setlocal bufhidden=hide
		setlocal nobuflisted
	enddef

	def CheckJobStatus(): bool
		return job_status(this._job) != 'dead'
	enddef


	def Clear()

		if bufname(this.bufnr) != ''

			if bufwinnr(this.bufnr) > 0
				view.DefaultWindowLayoutHidden()
			endif

			exe 'bdelete ' .. this.bufnr

		endif

		this.bufnr = -1
		this._view = null_object
		this.is_init = false
	enddef

	def Init(): bool

		if !this.CheckJobStatus()
			this.Clear()
		endif

		if this.is_init
			return true
		endif

		Log('create new Terminal')
		this._view = view.View.new()
		this._view.WindowLayoutOpen = this.WindowLayoutOpen
		this._view.WindowLayoutHidden = this.WindowLayoutHidden
		this._view.WindowLayoutOpen()
		this.bufnr = term_start(this.shell, this.options)
		this._job = term_getjob(this.bufnr)
		ConfigLocalTerminal()
		this._view.SetBufnr(this.bufnr)
		this.is_init = true
		return false
	enddef

	def new(WindowLayoutOpen: func = null_function, WindowLayoutHidden: func = null_function, shell = null_string)
		this.shell = executable(shell) ? shell : G.GetShell()
		this.WindowLayoutOpen = G.OR(WindowLayoutOpen, DefaultWindowLayoutOpen)
		this.WindowLayoutHidden = G.OR(WindowLayoutHidden, view.DefaultWindowLayoutHidden)
	enddef

	def JobEndCallback(j: job, status: number)
		this.Clear()
	enddef

	def Toggle()

		if !this.Init()
			return
		endif

		this._view.Toggle()

		if &bt[0] == 't'
			exe 'normal i'
		endif

	enddef

	static def DefaultWindowLayoutOpen()
		exec 'rightbelow :13 split'
	enddef

endclass

var t = Terminal.new()
def Test()
	t.Toggle()
	Log('termianl:', t)
	#nmap <leader>tt :call <SID>TH()<CR>
enddef
#g:Lt = () => Test()
#Test()
