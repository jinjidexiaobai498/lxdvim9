vim9script
def Config_local_termianl()
	setlocal nonumber norelativenumber signcolumn=no
	setlocal bufhidden=hide
	setlocal nobuflisted
	#autocmd WinEnter *[终端] <buffer> if mode() != 't' | exe "normal! i" endif
enddef

def TerminalClose(bufnr: number): bool
	if bufnr < 0 || bufname(bufnr) == ''
		return false
	endif

	#echom "test close start"

	var wid = bufwinnr(bufnr)
	var cwid = winnr()
	if wid == cwid
		close
	else
		win_gotoid(wid)
		close
		win_gotoid(cwid)
	endif

	var tjob = term_getjob(bufnr)
	if tjob  != null_job && job_status(tjob) != 'dead'
		return true
	endif

	exec "bdelete! " .. bufnr
	return false

enddef

export class Terminal
	this.options = {curwin: 1, norestore: 1, term_finish: 'open', term_kill: 'kill'} 
	this.name: string
	this.bufnr = -1
	this.job: job
	public this.shell: string
	public this.position: string
	public this.height: number
	static def GetNewName(): string
		var ID = get(g:, "__termianl_generate_id__", 1)
		g:__terminal_generate_id = ID + 1
		return "__terminal_" .. ID .. "_bid__"
	enddef


	def new( pos = "rightbelow", height = 13, shell = null_string)
		this.shell = (shell == null_string ? &shell : shell )
		this.position = pos
		this.height = height
		this.name = GetNewName()
		this.options.exit_cb = funcref(Terminal_exit, [this.name])
	enddef


	def GetBufnr(): number
		if this.bufnr > 0 && bufname(this.bufnr) != ''
			return this.bufnr
		endif
		this.bufnr = get(t:, this.name, -1)
		return this.bufnr
	enddef

	def SetBufnr(bufnr: number)
		this.bufnr = bufnr
		exe "t:" .. this.name .. " = " .. bufnr
	enddef

	def Restore(): bool
		if this.bufnr > 0 && bufname(this.bufnr) != ''
			var wid = bufwinnr(this.bufnr)
			if wid < 0 
				exec this.position .. " :" .. this.height .. " split"
				exec "buffer " .. this.bufnr
			else
				win_gotoid(wid)
			endif

			#insert
			if mode() != 't'
				exec "normal! i"
			endif

			return true
		endif
		return false
	enddef

	def Create()
		#decide cwd TODO
		exec this.position .. " :" .. this.height .. "split"
		this.SetBufnr(term_start(this.shell, this.options))
		this.job = term_getjob(this.bufnr)
		#b:__terminal_job__ = this.job
	enddef

	def Open()
		if !this.Restore() |  this.Create() | endif
		Config_local_termianl()
	enddef

	def Close()
		if !TerminalClose(this.bufnr)
			this.SetBufnr(-1)
		endif
	enddef

	def Toggle()
		#echom "test Toggle"
		if this.bufnr > 0 && bufname(this.bufnr) != '' && bufwinnr(this.bufnr) > 0
				this.Close()
			else
				this.Open()
			endif
	enddef
endclass

export def TerminalToggle(term: Terminal)
	term.Toggle()
enddef


def TerminalOpen(t: Terminal)
	t.Open()
enddef

def Terminal_exit(name: string, j: job, status: number )
	var bufnr = get(t:, name, -1)
	if bufnr < 0 || bufname(bufnr) == ''
		exe "t:" .. name .. " = " .. "-1"
		return
	endif
	exec "bdelete! " .. bufnr
enddef

