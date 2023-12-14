vim9script noclear
const SHELL_LIST = ['/bin/zsh', '/bin/bash', '/bin/sh']

def GetShell(): string
	for s in SHELL_LIST

		if executable(s)		
			
			return s->copy() 

		endif
		
	endfor
	return &shell
enddef


def Config_local_terminal()
	setlocal nonumber norelativenumber signcolumn=no
	setlocal bufhidden=hide
	setlocal nobuflisted
	#autocmd WinEnter *[终端] <buffer> if mode() != 't' | exe "normal! i" endif
enddef

var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef

def TerminalClose(bufnr: number): bool

	Log("DEF TerminalClose")
	if bufnr < 0 || bufname(bufnr) == ''
		Log("Buffer has been deleted\n ENDDEF")
		return false
	endif

	var wid = bufwinnr(bufnr)
	var cwid = winnr()
	if wid == cwid
		Log("Current windows is Terminal Window, " .. wid)
		close
	else
		Log("Goto Terminal Window " .. wid .. "And back")
		assert_true(win_gotoid(win_getid(wid)) != 0, 'cannot find the window by winnr : ' .. wid)
		close
		assert_true(win_gotoid(win_getid(cwid)) != 0, 'cannot find the window by winnr : ' .. cwid)
	endif

	var tjob = term_getjob(bufnr->copy())
	if tjob  != null_job && job_status(tjob) != 'dead'
		Log("Binding terminal job is living")
		return true
	endif
	Log("Binding terminal job is dead, delete! this buffer")

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
		var ID = get(g:, "__terminal_generate_id__", 1)
		g:__terminal_generate_id__ = ID + 1
		Log("new name is t:__terminal_" .. ID .. "_bid__")
		return "__terminal_" .. ID .. "_bid__"
	enddef


	def new( pos = "rightbelow", height = 13, shell = null_string)
		Log("Create new Terminal-help instance")
		this.shell = (shell == null_string ? GetShell() : shell )
		Log("shell: " .. this.shell)
		Log("position and height: " .. pos .. " " .. height)
		this.position = pos
		this.height = height
		this.name = GetNewName()
		this.options.exit_cb = funcref(Terminal_exit, [this.name->copy()])
	enddef


	def GetBufnr(): number
		if this.bufnr > 0 && bufname(this.bufnr) != ''
			return this.bufnr->copy()
		endif
		this.bufnr = get(t:, this.name, -1)
		return this.bufnr->copy()
	enddef

	def SetBufnr(bufnr: number)
		this.bufnr = bufnr
		exe "t:" .. this.name .. " = " .. bufnr
	enddef

	def Restore(): bool
		Log("Try Restore Terminal ...")
		var nr = this.GetBufnr()
		if nr > 0 && bufname(nr) != ''
			var wid = bufwinnr(nr)
			if wid < 0 
				exec this.position .. " :" .. this.height .. " split"
				exec "buffer " .. nr
				Log("create new Window: " .. winnr())
			else
				assert_true(win_gotoid(win_getid(wid)) != 0, 'cannot find the window by winnr : ' .. wid)
			endif

			#insert
			if mode() != 't'
				exec "normal! i"
			endif

			Log("sucessful")

			return true
		endif
		Log("failed")
		return false
	enddef

	def Create()
		Log("Create new Terminal-help")

		#decide cwd TODO
		var pwid = winnr()

		exec this.position .. " :" .. this.height .. "split"
		this.SetBufnr(term_start(this.shell, this.options))

		Log("Create new term by term_start, bufnr" .. this.bufnr)

		#to avoid stack overloop and kill the origin window buffer
		var wid = winnr()
		assert_true(win_gotoid(win_getid(pwid)) != 0, 'cannot find the window by winnr : ' .. pwid)
		assert_true(win_gotoid(win_getid(wid)) != 0, 'cannot find the window by winnr : ' .. wid)


		this.job = term_getjob(this.GetBufnr())
		Log("new Job , jobinfo: " .. job_info(this.job)->string())
		#b:__terminal_job__ = this.job
	enddef

	def Open()
		if !this.Restore() |  this.Create() | endif
		Config_local_terminal()
	enddef

	def Close()
		if !TerminalClose(this.GetBufnr())
			this.SetBufnr(-1)
		endif
	enddef

	def Toggle()
		Log("Toggle Terminal buf: " .. this.bufnr)
		#echom "test Toggle"
		var nr = this.GetBufnr()
		if nr > 0 && bufname(nr) != '' && bufwinnr(nr) > 0
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

def GotoWin(winnr: number)

	try
		:exe ':' .. winnr .. " wincmd w"
	catch /^Vim\%((\a\+)\)\=:E16:/
		Log('Error on range format')
		# TODO
	endtry
	assert_true(winnr == winnr(), 'go to window ' .. winnr .. ' failed')
enddef


export def Setup()
	g:hort_term = Terminal.new()
	g:vert_term = Terminal.new("vert bo", 37)
	nnoremap <Plug>HortTerminalToggle :call <SID>TerminalToggle(g:hort_term)<cr>
	tnoremap <Plug>HortTerminalToggle <c-\><c-n>:call <SID>TerminalToggle(g:hort_term)<cr>
	nnoremap <Plug>VertTerminalToggle :call <SID>TerminalToggle(g:vert_term)<cr>
	tnoremap <Plug>VertTerminalToggle <c-\><c-n>:call <SID>TerminalToggle(g:vert_term)<cr>
enddef

