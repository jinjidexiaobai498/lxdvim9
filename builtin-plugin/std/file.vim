vim9script
import './global.vim' as G
const EORROR_FLAG = 'builtin-plugin-File:'
const __FILE__ = expand('<sfile>')
var debug = false
var info = true
var Log = G.GetLog(debug, __FILE__)
var Info = G.GetInfo(info)
var AssertTrue = G.GetAssertTrue(__FILE__ .. EORROR_FLAG)
var AssertFalse = G.GetAssertFalse(__FILE__ .. EORROR_FLAG)

export class File
	this.path: string
	this.fullpath: string
	this.directory: string
	this.buffer: list<string>
	this.len = 0
	this.is_sync = true

	static def CreateFile(path: string, init_content: list<string> = ['']): bool
		var dt = fnamemodify(path, ":p:h")
		Log("parent directory", dt)
		if !isdirectory(dt) && !mkdir(dt, 'p')
			return false
		endif

		if !(init_content->writefile(path, 's') == 0)
			Info("Create new file path of " .. path .. "failed")
			return false
		endif

		return true
	enddef

	static def WriteFile(path: string, buf: list<string>): bool
		if writefile(buf, path, 's') == 0
			return true
		else 
			Info(' Write file:', path, 'failed , content: ', buf->string(), "")
			return false
		endif
	enddef

	def new(file_path: string, init_content: list<string> = [''], is_created_flag = true)
		this.path = file_path
		this.fullpath = fnamemodify(expand(this.path), ":p")
		this.directory = fnamemodify(this.fullpath, ":h")
		Log('fullpath:', this.fullpath)

		var is_exsited = !(!filereadable(this.fullpath))
		if !is_exsited && is_created_flag 
			is_exsited = CreateFile(this.path, init_content)
		endif
		AssertTrue(is_exsited, "EORROR path doesnot exist, path: " .. this.path)
		this.Sync()
	enddef

	def ContainsLine(str: string): bool
		return this.buffer->index(str) != -1
	enddef

	def IndexOf(str: string): number
		return this.buffer->index(str)
	enddef

	def Get(idx: number): string
		return this.buffer[idx]
	enddef

	def SetLines(lines: list<string>)
		this.buffer = lines->copy()
		this.is_sync = false
	enddef

	def Insert(idx: number, item: string)
		this.is_sync = false
		this.buffer->insert(item, idx)
	enddef

	def Set(idx: number, str: string)
		this.is_sync = false
		this.buffer[idx] = str
	enddef

	def Len(): number
		return this.len
	enddef

	def Append(str: string)
		this.is_sync = false
		this.buffer->add(str)
		this.len += 1
	enddef

	def Remove(idx: number): string
		this.is_sync = false
		return this.buffer->remove(idx)
	enddef

	def  Write()
		this.is_sync = true
		AssertTrue(WriteFile(this.fullpath, this.buffer), 'use def Write: failed : Object', this->string())
	enddef

	def Sync()
		if this.is_sync
			this.buffer = readfile(this.fullpath)
			this.len = len(this.buffer)
			return 
		endif
		this.Write()
		this.is_sync = true
	enddef

	def GetLines(): list<string>
		return this.buffer->copy()
	enddef

endclass

def Test()
	var f = File.new('./test.vim')
	#f.Remove(2)
	var l = f.Len()
	f.Append('###')
	var c = f.Get(0)
	c = '/'
	l += 1
	echo l
	var ls = f.GetLines()
	ls->add('#')
	Info('ls', ls)
	f.Sync()
	echo f
enddef
def Test1()
	#writefile(['hello'], '/home/lxd/pp/h.txt', 's')
	var f = File.new('/home/lxd/pp/h.txt', ['hello'])
enddef
#Test1()

