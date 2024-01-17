vim9script

import './global.vim' as G
import './view.vim' as view
import './project.vim' as project

const __FILE__ = expand('<sfile>')
var debug = true
var Log = G.GetLog(debug, __FILE__)
var AssertTrue = G.GetAssertTrue(__FILE__)

export class Terminal
	this.options = {curwin: 1, norestore: 1, term_finish: 'open', term_kill: 'kill', exit_cb: (_job, status) => view.ClearBufferWindow(this.bufnr)} 
	this.bufnr: number = -1
	this.shell: string
	this.WindowLayoutOpen: func
	this.WindowLayoutHidden: func
	this._view: view.View
	this._job: job = null_job

	this.is_cwd = false
	this.is_init = false

	this.open_bufnr = -1


	static def DefaultTerminalWindowLayoutOpen()
		exec 'rightbelow :13 split'
	enddef

	def new(WindowLayoutOpen: func = null_function, WindowLayoutHidden: func = null_function, shell = null_string, is_cwd = false)
		this.is_cwd = is_cwd
		this.shell = executable(shell) ? shell : G.SEHLL
		this._view = view.View.new(-1, G.OR(WindowLayoutOpen,  DefaultTerminalWindowLayoutOpen), G.OR(WindowLayoutHidden, view.SafeCloseWindow))
	enddef

	def Init()
		if this.is_init
			return
		endif

		Log('create new Terminal')
		if this.is_cwd
			this.options.cwd = project.GetProjectRoot()
			this.open_bufnr = bufnr()
		endif

		this._view.WindowLayoutOpen()
		this.bufnr = term_start(this.shell, this.options)
		this._job = term_getjob(this.bufnr)
		view.ConfigLocalHiddenToggleBuffer()
		this._view.SetBufnr(this.bufnr)
		this.is_init = true
	enddef

	def Toggle()
		if this.is_init && job_status(this._job) != 'run'
			view.ClearBufferWindow(this.bufnr)
			this.is_init = false
		endif
		
		if !this.is_init
			this.Init()
			return
		endif
		
		if this.is_cwd && !this._view.GetIsView() && bufnr() != this.open_bufnr
			this.open_bufnr = bufnr()
			var cwd = project.GetProjectRoot()
			if cwd != this.options.cwd
				term_sendkeys(this.bufnr, "cd " .. cwd .. "\<c-j>")
				this.options.cwd = cwd
			endif
		endif

		this._view.Toggle()

		if &bt[0] == 't' && mode() != 't'
			exe 'normal i'
		endif

	enddef

endclass

def Test()
	var t = Terminal.new(null_function, null_function, null_string, true)
	g:Lt = () => t.Toggle()
	nnoremap <c-x> :call g:Lt()<CR>
	tnoremap <c-x> <C-\><C-n>:call g:Lt()<CR>
enddef

#Test()
