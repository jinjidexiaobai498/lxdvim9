vim9script

import './global.vim' as G
import './view.vim' as view

const __FILE__ = expand('<sfile>')

var Assert = G.GetAssertTrue(__FILE__)
var debug = true
var Log = G.GetLog(debug, __FILE__)

export class Termianl

	this.options = {curwin: 1, norestore: 1, term_finish: 'open', term_kill: 'term'} 
	this.name: string
	this._job: job
	this.bufnr: number = -1
	this.shell: string
	this.is_sync = false
	this.is_init = false
	this._view: view.View
	this.Show: func
	this.Hidden: func


	static def ConfigLocalTerminal()
		setlocal nonumber norelativenumber signcolumn=no
		setlocal bufhidden=hide
		setlocal nobuflisted
	enddef


	def Sync()
		if this.bufnr != -1 
			this.is_job_end = job_status(this._job) == 'dead'
		endif
	enddef

	def Init()
		if this.is_init
			#this.Sync()
			return
		endif
		this.bufnr = term_start(this.shell, this.options)
		ConfigLocalTerminal()
		this._job = term_getjob(this.bufnr)
		this._view = view.View.new(this.bufnr)
		this._view.Toggle()
		this._view.Show = this.Show != null_function ? this.Show : this.DefaultShow
		this._view.Hidden = this.Hidden != null_function ? this.Hidden : this.DefaultHidden
		this.is_init = true
	enddef

	def new(shell = null_string, Show: func = null_function, Hidden: func = null_function)
		this.options.exit_cb = this.JobEndCallback
		this.shell = shell != null_string ? shell : G.GetShell()
		this.Show = Show
		this.Hidden = Hidden
	enddef

	def JobEndCallback(j: job, status: number)
		#this.is_job_end = true
		this.is_init = false
		if this.IsExists()
			exe 'bdelete ' .. this.bufnr
		endif
	enddef
	def Toggle()
		this.Init()
		this._view.Toggle()
	enddef

	def DefaultShow()
		#exec this.position .. " :" .. this.height .. "split"
		exec 'rightbelow :13 split'
		exec 'b ' .. this.bufnr
	enddef

	def DefaultHidden()
		try
			close
		catch /^Vim\%((\a\+)\)\=:E444:/
			exe 'vs'
			var winnr = winnr() + 1
			exe 'e 1'
			exe winnr .. 'close'
		endtry
	enddef

endclass

def Test()
	var t = Termianl.new()
	t.Toggle()
	Log('termianl:', t)
enddef
#g:Lt = () => Test()
