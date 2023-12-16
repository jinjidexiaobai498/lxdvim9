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
var Log = g.GetLog(debug)
var AssertTrue = g.GetAssertTrue('Project-Session-List')

export class SessionList 
	this.menu_list: file.File
	this.session_maps: dict<string>
	this.view_lines: list<string>
	this.removes: list<number>
	this.lines: list<string>
	this.is_sync = true
	this.option = {}

	def new()
		if !isdirectory(SESSION_DIR) 
			AssertTrue(mkdir(SESSION_DIR, "p"))
		endif
		if !filereadable(MENU_LIST_FILE_PATH)
			AssertTrue(writefile(['# Vim-Session-Project'], MENU_LIST_FILE_PATH, 's') == 0, 'init Session-Project menu-list-file failed')
		endif
		#this.session_list = globpath(SESSION_DIR, "*.vim", 0, 1)
		this.menu_list = file.File.new(MENU_LIST_FILE_PATH)
	enddef

	def Save()

		g.CloseNerdTree()
		var p = project.Project.new()
		var save_path = TranPathToFilename(p.project_path) .. '.vim'

		Log('save_path: ' .. save_path) 

		var ses = session.Session.new(save_path, SESSION_DIR)

		ses.SaveForce()

		if !this.menu_list.ContainsLine(save_path)
			this.menu_list.Append(save_path)
			defer this.menu_list.Sync()
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
	enddef

	def Sync()

		if this.is_sync
			return
		endif

		uniq(sort(this.removes))

		var dis = 0
		for i in this.removes
			this.menu_list.Remove(i - dis)
			dis += 1
		endfor

		this.menu_list.Sync()
		this.removes = []
		this.is_sync = true
	enddef

	def Filter(winid: number, key: string): bool
		if key == 'r'
			this.is_sync = false
			win_execute(winid, '@l = line(".")')
			var lnum = str2nr(@l) 

			if lnum == 1 
				return true
			endif


			var idx = lnum - 1
			@l = (lnum)->string()
			var ip = this.removes->index(idx)

			if ip != -1
				@t = this.view_lines[idx]
				this.removes->remove(ip)
			else
				@t = '[x]' .. this.view_lines[idx]
				this.removes->add(idx)
			endif

			win_execute(winid, 'setline(str2nr(@l), @t)')

			Log('lnum: ', lnum)
			Log('this.removes:', this.removes)

			return true

		elseif key == 'q'
			popup_close(winid, -1)
			return true
		else
			return popup_filter_menu(winid, key)
		endif
	enddef

	def Callback(winid: number, result: any)

		Log('callback result:', result)

		var idx = result - 1
		if idx > 0 && idx < len(this.lines) && this.removes->index(idx) == -1
			Log('idx: ', idx)
			Log('this.lines: ', this.lines)

			var path = SESSION_DIR .. "/" .. this.lines[idx]
			if !filereadable(path)
				echom " path does not exists :" .. path
				this.removes->add(idx)
			else
				exec "source " .. path
			endif
		endif

		if result != -1
			this.Sync()
		endif

	enddef

	def SyncDispLines(): number
		var disp_lines = this.menu_list.GetLines()
		var i = 0
		var len = len(disp_lines)
		var maxwidth = 0
		while i < len
			disp_lines[i] = TranFilenameToPath(disp_lines[i])
			var tl = len(disp_lines[i])
			maxwidth = tl > maxwidth ? tl : maxwidth
			i += 1
		endwhile
		this.view_lines = disp_lines
		Log('disp_lines: ', this.view_lines)
		return maxwidth
	enddef

	def PopupBrowser()

		this.menu_list.Sync()
		this.removes = []
		this.lines = this.menu_list.GetLines()
		var maxwidth = this.SyncDispLines()

		var winid = popup_menu(this.view_lines, {
			maxheight: 100,
			minheight: 5,
			maxwidth: 200,
			minwidth: maxwidth + 3,
			callback: this.Callback,
			filter: this.Filter
		})

		win_execute(winid, 'setlocal cursorline')
	enddef


endclass

export def TranFilenameToPath(str: string): string
	return substitute(str, '%', '', 'g')
enddef

def TranPathToFilename(path: string): string
	return fnameescape(substitute(path, '/', '%', 'g'))
enddef


#Test3()
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

def TestSave()
	var sl = SessionList.new()
	sl.Save()
	sl.SyncDispLines()
	echom sl->string()
enddef

def TestList()
	var sl = SessionList.new()
	#sl.Save()
	sl.PopupBrowser()
enddef

#g:Test = TestList
#TestList()
#TestSave()

