vim9script
import './global.vim' as G

const EORROR_FLAG = 'builtin-plugin-File'
var debug = false
var info = true
var Log = G.GetLog(debug)
var Info = G.GetInfo(info)
var AssertTrue = G.GetAssertTrue(EORROR_FLAG)
var AssertFalse = G.GetAssertFalse(EORROR_FLAG)

export class File
	this.path: string
	this.fullpath: string
	this.buffer: list<string>
	this.is_exsited: bool
	this.len = 0
	this.sync = true
	def new(path: string, flag = true)

		var p = expand(path)
		this.is_exsited = filereadable(p)

		if flag && !this.is_exsited
			AssertTrue(['#']->writefile(p, 's') == 0, "Create new file path of " .. path .. "failed")
		endif

		AssertTrue(this.is_exsited, "EORROR path doesnot exist, path: " .. path)

		this.path = path
		this.fullpath = p
		this.buffer = readfile(p)
		this.len = len(this.buffer)

		if flag
			AssertTrue(empty(this.buffer) != 1, 'empty of file ' .. this.fullpath)
		endif

	enddef

	def ContainsLine(str: string): bool
		return this.buffer->index(str) != -1
	enddef

	def Get(idx: number): string
		return this.buffer[idx]->copy()
	enddef

	def SetLines(lines: list<string>)
		this.buffer = lines->copy()
		this.sync = false
	enddef

	def CheckIndex(idx: number): bool
		AssertFalse((idx > this.len || idx + this.len <= 0), G.DArgs(idx, 'out of index in object', this))
		return true

	enddef

	def Insert(idx: number, item: string)


	enddef

	def Set(idx: number, str: string)
		this.sync = false
		if idx >= this.len
			this.buffer->add(str)
			return
		endif
		this.buffer[idx] = str->copy()
	enddef

	def Len(): number
		return this.len->copy()
	enddef

	def Append(str: string)
		this.sync = false
		this.buffer->add(str)
		#AssertTrue(writefile([str], this.fullpath, 'a') == 0, 'use def Append: failed , Object of' .. this->string())
		this.len += 1
	enddef

	def Remove(idx: number): string
		this.CheckIndex(idx)
		this.sync = false
		var res = this.buffer->remove(idx)
		#AssertTrue(res->string() != '0', 'def Remove() failed of object' .. this->string())
		Log('res: ', res)
		return res->string()
	enddef

	def  Write()
		this.sync = true
		AssertTrue(writefile(this.buffer, this.fullpath, 's') == 0, 'use def Write: failed : Object' .. this->string())
	enddef

	def Sync()
		if !this.sync
			this.Write()
		endif
	enddef

	def GetLines(): list<string>
		return this.buffer->copy()
	enddef

	def Print()
		echom this.buffer->string()
	enddef

endclass

def GetParentPath(path: string): string
	var last_index = path->strridx('/')

	if last_index == 0 
		return null_string 
	endif

	return path[ : last_index - 1]

enddef

def Test()
	#	writefile(['a'], '~/llt.txt', 'p')
	#AssertTrue(false, 'hello', 'what')
	#Info('xxx', 'yyy')
enddef
Test()
