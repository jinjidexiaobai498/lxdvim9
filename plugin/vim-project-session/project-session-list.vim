vim9script
import "../std/session.vim" as session
import "../std/global.vim" as g
import "../std/project.vim" as project
import "../std/file.vim" as file
import "../std/collections.vim" as col
var LIST_NAME: string = "list.txt"
var SESSION_DIR_NAME: string  = "session_histroy"
var SESSION_DIR: string = g.DATA_DIR .. "/" ..  SESSION_DIR_NAME
var MENU_LIST_FILE_PATH: string = SESSION_DIR .. "/" .. LIST_NAME

var debug = false
def Log(msg: string)
	if debug
		echom msg
	endif
enddef

export class SessionList
	#this.session_list: list<session.Session>
	this.menu_list: file.File
	this.session_maps: dict<string>

	def new()
		if !isdirectory(SESSION_DIR) 
			assert_true(mkdir(SESSION_DIR, "p"))
		endif
		if !filereadable(MENU_LIST_FILE_PATH)
			assert_true(writefile(['# Vim-Session-Project'], MENU_LIST_FILE_PATH, 's') == 0, 'init Session-Project menu-list-file failed')
		endif
		#this.session_list = globpath(SESSION_DIR, "*.vim", 0, 1)
		this.menu_list = file.File.new(MENU_LIST_FILE_PATH)
	enddef

	def Save()
		var p = project.Project.new()
		var save_name = TranPathToFilename(p.name)
		var save_path =  save_name .. "__.vim"
		Log('save_path: ' .. save_path) 
		var ses = session.Session.new(save_path, SESSION_DIR)
		ses.SaveForce()

		if !this.menu_list.ContainsLine(save_path)
			this.menu_list.Append(save_path)

		endif

	enddef

	def Remove(idx: number): string
		var filename = this.menu_list.Remove(idx)
		Log('Removed filename: ' .. filename)
		var path = SESSION_DIR .. '/' .. filename
		Log("path of session.vim to save: " .. path)
		if filereadable(path)
			assert_true(delete(path) == 0, 'def Remove failed in delete file, of object' .. this->string())
		endif
		return filename
		#return null_string
	enddef

	def PopupBrowser()

		Log('Start PopupBrowser-------')
		var disp_lines = this.menu_list.GetLines()->copy()
		var i = 0
		var len = len(disp_lines)
		while i < len
			disp_lines[i] = substitute(disp_lines[i], '__', '/', 'g')
			i += 1
		endwhile

		Log('disp_lines: ' .. disp_lines->string())

		var lines = this.menu_list.GetLines()

		var winid = popup_menu(disp_lines, {
			callback: (_, result) => {
				if result > 1
					var path = SESSION_DIR .. "/" .. lines[result - 1]
					if !filereadable(path)
						var idx = result - 1
						Log(" Remove idx: " .. idx->string()) 
						this.Remove(result - 1)
					else
						exec "source " .. path
					endif
				endif
			},
			filter: (id, key) => {
				if key == 'q'
					popup_close(id, 0)
				else
					popup_filter_menu(id, key)
				endif
				return true
			}
		})
		win_execute(winid, 'setlocal cursorline')
	enddef

	def TestDefault()
		popup_menu(['111', '222', '3333'], {
			callback: (_, result) => {
				echom 'dialog ' .. result
			},
			filter: (id, key) => {
				return popup_filter_menu(id, key)
			}
		})
	enddef

	static def TranPathToFilename(path: string): string
		var old_magic = &magic
		&magic = 0
		var ss = substitute(path, '/', '__', 'g') 
		&magic = old_magic
		return ss
	enddef

endclass

export def PopupBrowser(psl: SessionList)
	Log('start popupbrowser ....')
	psl.PopupBrowser()
enddef

export def Save(psl: SessionList)
	psl.Save()
enddef


export def Setup()
	g:session_list_vim = SessionList.new()
	nmap <Plug>PSLPopupBrowser :call <SID>PopupBrowser(g:session_list_vim)<CR>
	nmap <Plug>PSLSave :call <SID>Save(g:session_list_vim)<CR>
enddef

def TestList()
	var sl = SessionList.new()
	sl.Save()
	sl.PopupBrowser()
enddef

#g:Test = TestList

def Test2()
	var oldfiles = ''
	:redir => oldfiles
	exe 'oldfiles'
	:redir END
	echom oldfiles->string()->split('\n')
enddef
#Test2()
