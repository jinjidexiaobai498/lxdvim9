vim9script
import "./file.vim" as file
import "./session.vim" as s

#var PROJECT_LABLE = ['.git', 'Cargo.toml', 'CMakeList.txt', 'Makefile', 'package.json']

var PROJECT_LABLE = {'.git': "git", "Cargo.toml": "Cargo", 'CMakeList.txt': "CMake", "Makefile": "make", "package.json": "node"}

var LANGUIAGE_MAP = {'c': "c", "cpp": 'cpp', 'py': 'python', 'rs': 'rust', 'md': 'markdown', 'js': "javascript", 'css': 'css', 'html': 'html', "xml": 'xml', 'toml': 'toml', 'json': 'json'}

var debug = false

def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export class Project
	#TODO finish multi times mem buffer
	#static workdir_buffer_map: dict<string>
	public this.path: string = null_string
	public this.name: string = null_string
	public this.type: string = null_string
	public this.filename: string = null_string
	def new(path = null_string)
		if path != null_string
			this.filename = fnamemodify(expand(path), ':p')
			this.path = GetParentPath(this.filename)
		else
			this.filename = fnamemodify(expand('%'), ':p') 
			this.path = GetParentPath(this.filename)
		endif
		Log("filename: " .. this.filename .. ", path: " .. this.path)
		
		var p = this.path->copy()
		while p != null_string
			var subs = readdir(p)
			for i in PROJECT_LABLE->keys()
				if subs->index(i) != -1 
					this.name = p->copy()
					this.type = PROJECT_LABLE->get(i, 'NONE')
					p = null_string
					break
				endif
			endfor

			if p != null_string
				p = GetParentPath(p)
			endif
			
		endwhile
		if this.name == null_string
			this.name = this.filename
			this.type = 'SingleFile'
		endif
	enddef

	static def GetParentPath(path: string): string
		var last_index = path->strridx('/')

		if last_index == 0 
			return null_string 
		endif

		return path[ : last_index - 1]

	enddef
endclass


def TestProject()
	#var Pj = Project.new("/home/lxd/Downloads/alacritty.yml")
	var Pj = Project.new()
	echom Pj.type
	echom Pj.name
	echom Pj.filename
enddef

def Test()
	var path = '/home/lxd'
	var par = Project.GetParentPath(path)
	echom par
	var c = expand('%')
	var p = fnamemodify(c, ':p')
	echom p 
enddef

#g:Test = TestProject
#TestProject()
