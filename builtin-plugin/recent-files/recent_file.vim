vim9script

import '../std/global.vim' as G
import '../std/file.vim' as file
import "../std/collections.vim" as cols const FILE_NAME = 'recent_file.vimd'
const FILE_PATH = G.DATA_DIR
export var MAX_LEN = 30
export var debug = false

def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export class RecentFile
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
	var i = str->stridx(':') + 2
	exe 'edit ' .. str->slice(i)
enddef

def GetOldFiles()
	exec 'oldfiles'
enddef

export def RecentFiles()
	var oldfiles = ''
	redir => oldfiles
	silent call GetOldFiles()
	redir END

	var flist = oldfiles->split('\n')->slice(0, MAX_LEN)
	Log(oldfiles->string())
	Log(flist->string())

	call fzf#run(fzf#wrap({'source': flist, 'sink': Sink}))
enddef

export def Setup()
	nmap <silent> <Plug>RecentFiles :call <SID>RecentFiles()<CR>
enddef


#RecentFiles()
