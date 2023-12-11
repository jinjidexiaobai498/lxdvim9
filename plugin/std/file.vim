vim9script

var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export class File
	this.path: string
	this.fullpath: string
	this.buffer: list<string>
	this.is_exsited: bool
	def new(path: string, flag = true)

		var p = expand(path)
		this.is_exsited = filereadable(p)

		if flag && !this.is_exsited
			assert_true(['#']->writefile(p, 's') == 0, "Create new file path of " .. path .. "failed")
		endif

		assert_true(this.is_exsited,  "EORROR path doesnot exist, path: " .. path)

		this.path = path
		this.fullpath = p
		this.buffer = readfile(p)

		if flag
			assert_true(empty(this.buffer) != 1, 'empty of file ' .. this.fullpath)
		endif

	enddef

	def ContainsLine(str: string): bool
		return this.buffer->index(str) != -1
	enddef

	def Append(str: string)
		this.buffer->add(str)
		assert_true(writefile([str], this.fullpath, 'a') == 0, 'use def Append: failed , Object of' .. this->string())
	enddef

	def Remove(idx: number): string
		var res = this.buffer->remove(idx)
		assert_true(res->string() != '0', 'def Remove() failed of object' .. this->string())
		this.Write()
		Log('res: ' .. res->string())
		return res->string()
	enddef

	def  Write()
		assert_true(writefile(this.buffer, this.fullpath, 's') == 0, 'use def Write: failed : Object' .. this->string())
	enddef

	def GetLines(): list<string>
		return this.buffer
	enddef

	def Print()
		echom this.buffer->string()
	enddef

	static def GetParentPath(path: string): string
		var last_index = path->strridx('/')

		if last_index == 0 
			return null_string 
		endif

		return path[ : last_index - 1]

	enddef
endclass
