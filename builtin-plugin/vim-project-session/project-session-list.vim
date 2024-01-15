vim9script
import "../std/global.vim" as G
import "../std/session.vim" as ses
import "../std/project.vim" as project 
import "../std/file.vim" as file 
import "../std/collections.vim" as col

const LIST_NAME: string = "list.txt"
const SESSION_DIR_FILENAME: string  = "session_histroy"
const SESSION_DIR_FULL_PATH: string = [G.DATA_DIR, SESSION_DIR_FILENAME]->join(G.Backslash)
const MENU_LIST_FILE_PATH: string = [SESSION_DIR_FULL_PATH,  LIST_NAME]->join(G.Backslash)
const DELETE_KEY_MAP = {'r': true, 'x': true, 'd': true}
const EXIT_KEY_MAP = {'q': true}
const EXIT_BUT_NOT_SELECT = {'g': true, "\<Space>": true}
const SELECT_KEY_MAP = {'s': true}

var debug = true
var Log = G.GetLog(debug)
var Info = G.GetLog(true)
var AssertTrue = G.GetAssertTrue('Project-Session-List')

export class SessionList 
	this.menu_list_file: file.File
	this.remove_menu_index_map: dict<number> = {}
	this.session_workdir_list: list<string> = []
	this.removes: list<number> = []
	this.lines: list<string> =  []
	this.is_sync = true
	this.session: ses.Session

	# saved name in block file is like "\%home\%lxd\%Projetcs\%lxdvimrc"
	# the real file name is like "%home%lxd%Projects%lxdvimrc"
	static def TransSavedNameToFilename(sname: string): string
		Log('saved name', sname)
		return sname->substitute('\', '', 'g')
	enddef

	static def  TranSavedNameToPath(sname: string): string
		var s = sname
		if G.UseWindows
			s = sname[0] .. ':' ..  sname[3 : ]
		endif
		return substitute(s, '%', '', 'g')
	enddef

	static def TranPathToFilename(path: string): string
		var s = path
		if G.UseWindows
			s = substitute(path, ':', '%', 'g')
		endif
		Log('path:', s)
		var p = fnameescape(substitute(s, G.Backslash, '%', 'g')) 
		Log('filename:', p)
		return p
	enddef

	def new()
		#this.session_list = globpath(SESSION_DIR_FULL_PATH, "*.vim", 0, 1)
		this.menu_list_file = file.File.new(MENU_LIST_FILE_PATH, ['# Vim-Session-Project'])
	enddef

	def Save()
		G.CloseNerdTree()
		var session_filename = TranPathToFilename(project.GetProjectRootProto().name) .. '.vim'
		Log('session_filename: ' .. session_filename) 
		exe "mksession! " .. ([SESSION_DIR_FULL_PATH, session_filename]->join(G.Backslash))

		if !this.menu_list_file.ContainsLine(session_filename)
			this.menu_list_file.Append(session_filename)
			this.menu_list_file.Sync()
		endif

	enddef

	def SyncRemoves()
		if this.is_sync
			return
		endif
		uniq(sort(this.removes))
		var dis = 0
		for i in this.removes
			this.menu_list_file.Remove(i - dis)
			dis += 1
		endfor
		this.menu_list_file.Sync()
		this.removes = []
		this.is_sync = true
	enddef

	def Filter(winid: number, key: string): bool
		if DELETE_KEY_MAP->has_key(key)
			win_execute(winid, '@l = line(".")')
			var lnum = str2nr(@l) 
			if lnum == 1 
				return true
			endif

			this.is_sync = false
			var mlist_index = lnum - 1
			var rlist_index = this.removes->index(mlist_index)

			@t = this.session_workdir_list[mlist_index]
			if rlist_index != -1
				this.removes->remove(rlist_index)
			else
				@t = "[x]" .. @t
				this.removes->add(mlist_index)
			endif

			win_execute(winid, 'setline(str2nr(@l), @t)')
			Log('lnum: ', lnum)
			Log('this.removes:', this.removes)
		elseif EXIT_KEY_MAP->has_key(key)
			popup_close(winid, -1)
		elseif EXIT_BUT_NOT_SELECT->has_key(key)
			popup_close(winid, 1)
		elseif SELECT_KEY_MAP->has_key(key)
			win_execute(winid, '@l = line(".")')
			var lnum = str2nr(@l) 
			popup_close(winid, lnum)
		else
			return popup_filter_menu(winid, key)
		endif
		return true
	enddef

	def Callback(winid: number, result: any)
		Log('callback result:', result)
		if result == -1
			return
		endif

		var idx = result - 1
		if idx > 0 && idx < len(this.lines) && this.removes->index(idx) == -1
			Log('idx: ', idx)
			Log('this.lines: ', this.lines)

			var path = [SESSION_DIR_FULL_PATH, TransSavedNameToFilename(this.lines[idx])]->join(G.Backslash)
			Log('path:', path)
			if !filereadable(path)
				Info("path does not exists :", path)
				this.removes->add(idx)
				this.is_sync = false
			else
				exec "source " .. fnameescape(path)
			endif
		endif

		this.SyncRemoves()

	enddef

	def PreDealDispLines(): number
		var disp_lines = this.menu_list_file.GetLines()
		var i = 0
		var len = len(disp_lines)
		var maxwidth = 0
		while i < len
			disp_lines[i] = TranSavedNameToPath(disp_lines[i])
			var tl = len(disp_lines[i])
			maxwidth = tl > maxwidth ? tl : maxwidth
			i += 1
		endwhile
		this.session_workdir_list = disp_lines
		Log('disp_lines: ', this.session_workdir_list)
		return maxwidth
	enddef

	def PopupBrowser()
		this.menu_list_file.Sync()
		this.lines = this.menu_list_file.GetLines()
		var maxwidth = this.PreDealDispLines()
		var winid = popup_menu(this.session_workdir_list, {
			callback: this.Callback,
			filter: this.Filter,
			minwidth: maxwidth + 3
		})
		win_execute(winid, 'setlocal cursorline')
	enddef

endclass

var sl = SessionList.new()
var RunBrowser = () => sl.PopupBrowser()
export var RunSave = () => sl.Save()
export def Setup()
	nmap <Plug>PSLPopupBrowser :call <SID>RunBrowser()<CR>
	nmap <Plug>PSLSave :call <SID>RunSave()<CR>
	augroup LastSessionSave
		au!
		au VimLeave * call RunSave()
	augroup END
enddef

def Test()
	Setup()
	nmap <leader>tt <Plug>PSLPopupBrowser
	nmap <leader>ts <Plug>PSLSave
enddef

#Test()

