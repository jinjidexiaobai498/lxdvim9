vim9script
import "./session.vim" as s
import './global.vim' as G

var PROJECT_LABLE = {'.git': "git", "Cargo.toml": "Cargo", 'CMakeList.txt': "CMake", "Makefile": "make", "package.json": "node"}

var LANGUIAGE_MAP = {'c': "c", "cpp": 'cpp', 'py': 'python', 'rs': 'rust', 'md': 'markdown', 'js': "javascript", 'css': 'css', 'html': 'html', "xml": 'xml', 'toml': 'toml', 'json': 'json'}

var debug = true
var Log = G.GetLog(debug)

export const ProjectType = {
	SingleFile: 0,
	Project: 1
}

const ProjectTypeDecode = ['SingleFile', 'Project']

export class Project
	#TODO finish multi times mem buffer
	#static workdir_buffer_map: dict<string>
	this.file_path: string = null_string
	this.project_path: string = null_string
	this.type: number
	this.type_name: string
	this.filename: string = null_string
	this.project_name: string = null_string
	def new(path = null_string)
		Log("filename: " .. this.filename .. ", path: " .. this.file_path)
		var res = GetProjectRootProto(path)
		this.filename = res.filename
		this.file_path = res.file_path
		this.project_path = res.project_path
		this.type_name = res.type_name
		this.type = res.type
		this.project_name = res.name
	enddef

endclass

export def GetProjectRootProto(path = null_string): dict<any>
	var res = {}
	res.filename = fnamemodify(expand(path == null_string ? '%' : path->copy()), ':p')
	res.file_path = G.GetParentPath(res.filename)
	var p = res.file_path
	while p != null_string
		Log('parent dir', p)
		var subs = readdir(p)
		for i in PROJECT_LABLE->keys()
			if subs->index(i) != -1 
				res.project_path = p->copy()
				res.type_name = PROJECT_LABLE->get(i, 'NO_LABLE_PROJECT')
				res.type = ProjectType.Project
				res.name = p->copy()
				return res
			endif
		endfor
		p = G.GetParentPath(p)
	endwhile

	res.project_path = res.file_path
	res.type = ProjectType.SingleFile
	res.name = res.filename
	res.type_name = 'SINGLE_FILE'
	return res

enddef

export def GetProjectRoot(path = null_string): string
	var filename = fnamemodify(expand(path == null_string ? '%' : path->copy()), ':p')
	var parent_filename = G.GetParentPath(filename)
	var p = parent_filename
	while p != null_string
		Log('parent path', p)
		var subs = readdir(p)
		for i in PROJECT_LABLE->keys()
			if subs->index(i) != -1 
				return p
			endif
		endfor
		p = G.GetParentPath(p)
	endwhile
	return parent_filename
enddef

def TestProject()
	#var Pj = Project.new("/home/lxd/Downloads/alacritty.yml")
	var Pj = Project.new()
	echom Pj.type_name
	echom Pj.project_path
	echom Pj.filename
	var p = GetProjectRoot()
	echom 'root' p
enddef

def Test()
	var path = G.HOME
	var par = G.GetParentPath(path)
	echom par
	var c = expand('%')
	var p = fnamemodify(c, ':p')
	echom p 
enddef

#g:Test = TestProject
#TestProject()
