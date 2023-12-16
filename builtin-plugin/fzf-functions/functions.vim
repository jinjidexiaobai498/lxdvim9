vim9script

import '../std/global.vim' as G
import '../std/file.vim' as file
import "../std/collections.vim" as cols const FILE_NAME = 'recent_file.vimd'
const FILE_PATH = G.DATA_DIR
export var MAX_LEN = 30
export var debug = false

var Log = G.GetLog(debug)

export class FZFFunction
	this.rfile: file.File
	this.data: cols.Deque
	this.max_len = 0
	this.buffer: list<string> = null_list
	def new()
		this.rfile = file.File.new(FILE_PATH)
		this.max_len = MAX_LEN->copy()
		var l = this.rfile.Len()
		l = this.max_len > l ? l : this.max_len->copy()
		this.buffer = this.rfile.GetLines()->slice(0. l)
		this.data = cols.Deque.newDeque(this.buffer)
	enddef
endclass
export def Sink(str: string)
	echom str
	var start = str->stridx(' ') + 1
	var end = str->stridx(')') + 1
	Log('index of start of function name', start)
	echom str->slice(start, end)
	exe 'verbose function ' .. str->slice(start, end)
enddef

def GetFunctions()
	exec 'function'
enddef

export def Functions()
	var functions = ''
	redir => functions
	silent call  GetFunctions()
	redir END

	#var flist = functions->split('\n')->slice(0, MAX_LEN)
	var flist = functions->split('\n')
	Log(functions->string())
	Log(flist->string())

	call fzf#run(fzf#wrap({'source': flist, 'sink': Sink}))
enddef

export def Setup()
	nmap <silent> <Plug>Functions :call <SID>Functions()<CR>
enddef


Functions()
