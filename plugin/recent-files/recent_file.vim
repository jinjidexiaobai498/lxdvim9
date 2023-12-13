vim9script

import '../std/global.vim' as G
import '../std/file.vim' as file
import "../std/collections.vim" as cols
const FILE_NAME = 'recent_file.vimd'
const FILE_PATH = G.DATA_DIR
export var MAX_LEN = 20

export class RecentFile
	this.rfile = file.File.new(FILE_PATH)
	this.data: cols.Deque
	this.max_len = 0
	this.buffer: list<string> = null_list
	def new()
		this.max_len = MAX_LEN->copy()
		var l = this.rfile.Len()
		l = this.max_len > l ? l : this.max_len->copy()
		this.buffer = this.rfile.GetLines()->slice(0. l)
		this.data = cols.Deque.newDeque(this.buffer)
	enddef
endclass
