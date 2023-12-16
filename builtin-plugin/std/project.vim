vim9script
import "./file.vim" as file
import "./session.vim" as s
import './global.vim' as G

var PROJECT_LABLE = {'.git': "git", "Cargo.toml": "Cargo", 'CMakeList.txt': "CMake", "Makefile": "make", "package.json": "node"}

var LANGUIAGE_MAP = {'c': "c", "cpp": 'cpp', 'py': 'python', 'rs': 'rust', 'md': 'markdown', 'js': "javascript", 'css': 'css', 'html': 'html', "xml": 'xml', 'toml': 'toml', 'json': 'json'}

var debug = false
var Log = G.GetLog(debug)

export class Project
	#TODO finish multi times mem buffer
	#static workdir_buffer_map: dict<string>
	public this.file_path: string = null_string
	public this.project_path: string = null_string
	public this.type: string = null_string
	public this.filename: string = null_string
	def new(path = null_string)
		this.filename = fnamemodify(expand(path == null_string ? '%' : path->copy()), ':p')
		this.file_path = GetParentPath(this.filename)
		Log("filename: " .. this.filename .. ", path: " .. this.file_path)

		var p = this.file_path->copy()
		while p != null_string
			var subs = readdir(p)
			for i in PROJECT_LABLE->keys()
				if subs->index(i) != -1 
					this.project_path = p->copy()
					this.type = PROJECT_LABLE->get(i, 'NONE')
					p = null_string
					break
				endif
			endfor

			if p != null_string
				p = GetParentPath(p)
			endif

		endwhile

		if this.project_path == null_string
			this.project_path = this.file_path
			this.type = 'SingleFile'
		endif
	enddef

endclass

export def GetParentPath(path: string): string
	var last_index = path->strridx('/')

	if last_index == 0 
		return null_string 
	endif

	return path[ : last_index - 1]
enddef

def TestProject()
	#var Pj = Project.new("/home/lxd/Downloads/alacritty.yml")
	var Pj = Project.new()
	echom Pj.type
	echom Pj.project_path
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
