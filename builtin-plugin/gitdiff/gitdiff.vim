vim9script

import '../std/global.vim' as G
const __FILE__ = expand('<sfile>:p')
var debug = false
var Log = G.GetLog(debug, __FILE__)
var Info = G.GetLog(true, __FILE__)

export class BufferStatus
	this.status = 0

endclass

def IsStartLine(str: string): bool
	return str->match('^@@ -[0-9]*,[0-9]* +[0-9]*,[0-9]* @@') == 0
enddef

def GetStartLineMatchList(str: string): list<string>
	var res = (str->matchlist('^@@ -\([0-9]*\),\([0-9]*\) +\([0-9]*\),\([0-9]*\) @@'))
	if empty(res)
		return null_list
	endif
	return res->slice(3, 5)
enddef

export class GitDiffMsg
	static type_name_add	= 'git-diff-msg-add'
	static type_name_delete = 'git-diff-msg-delete'
	static type_name_empty	= 'git-diff-msg-empty'
	static type_name_change = 'git-diff-msg-change'
	static is_clear = true
	static commandlist: list<string> = ['git -C', ' ', 'diff HEAD --', ' ']
	static is_marked = false
	this.is_register = false
	this.is_init = true
	this.is_sync = true
	this.msglist: list<string>
	this.msg: string
	this.command: string
	this.filename: string
	this.dirname: string
	this.bufnr: number

	static def Clear()
		prop_remove({ type: 'git-diff-msg-add', all: true})
		prop_remove({ type: 'git-diff-msg-delete', all: true})
		is_clear = true
	enddef

	def Register()
		if this.is_register
			return
		endif
		hi GitDiffAdd term=bold ctermfg=Green  guifg=#00FF00
		hi GitDiffDelete term=bold ctermfg=Red  guifg=#FF0000 
		if empty(prop_type_get(type_name_add))
			prop_type_add(type_name_add, {highlight: 'GitDiffAdd'})
		endif
		if empty(prop_type_get(type_name_delete))
			prop_type_add(type_name_delete, {highlight: 'GitDiffDelete'})
		endif

		this.is_register = true

	enddef

	def new()
	enddef

	def GetCommand(): string
		this.filename = expand('%:p')
		this.dirname = expand('%:p:h')
		commandlist[1] = this.dirname
		commandlist[3] = this.filename
		return commandlist->join(' ')
	enddef

	def Sync()
		this.command = this.GetCommand()
		this.msglist = systemlist(this.command .. ' ; echo $?')

		if this.msglist[-1] != '0'
			Info('use git error, check this file is not in git charge', this.command)
			return
		endif
		this.msglist->remove(-1)
		#echo G.Inspect(this.msglist)
		this.is_sync = true
	enddef

	def Endline()
		is_clear = false
		this.is_sync = false
	enddef

	static def MarkAdd(lnum: number)
		prop_add(lnum, 1, { type: type_name_add, text: '│'})
	enddef

	static def MarkDelete(lnum: number)
		prop_add(lnum, 1, {type: type_name_delete, text: '-'})
	enddef

	static def ClearMark()
		prop_remove({type: 'git-diff-msg-add', all: true})
		prop_remove({type: 'git-diff-msg-delete', all: true})
		is_marked = false
	enddef

	def Mark()
		if is_marked
			return
		endif
		this.Register()
		Clear()
		this.Sync()
		var li = 0
		var LEN = len(this.msglist)
		var status_list = repeat([0], LEN)
		Log('LEN: ', LEN)
		var msgidx = li + 1

		while li < LEN
			var sml = GetStartLineMatchList(this.msglist[li])
			Log('sml', sml)
			msgidx = li + 1
			if msgidx >= LEN
				return
			endif

			if sml != null_list
				var start = sml[0]->str2nr()
				var sum_lines_off = sml[1]->str2nr()
				var end = start + sum_lines_off

				var is_last_delete = false
				var buflinenum = start
				var count = 0
				while count < sum_lines_off

					var first_char = empty(this.msglist[msgidx]) ? ' ' : this.msglist[msgidx][0]

					if first_char == '+'
						MarkAdd(buflinenum)
					elseif first_char == '-'
						if !is_last_delete
							MarkDelete(buflinenum > 1 ? buflinenum - 1 : 1)
						endif
					endif

					if first_char == ' ' || first_char == '+'
						buflinenum += 1
						count += 1
						is_last_delete = false
					else
						is_last_delete = true
					endif

					msgidx += 1
				endwhile
				msgidx -= 1

			endif

			li = msgidx->copy()

		endwhile

		is_marked = true
		this.Endline()
	enddef

	def ToggleMark()
		if is_marked
			ClearMark()
		else
			this.Mark()
		endif
	enddef

endclass

def ToggleMark(gdm: GitDiffMsg)
	gdm.ToggleMark()
enddef

export def Setup()
	g:__git_diff_msg__ = GitDiffMsg.new()
	nmap <Plug>ToggleGitDiffMark :call <SID>ToggleMark(g:__git_diff_msg__)<CR>
	var flag = get(g:, 'GitDiffMsgEnable', false)
	if flag
		augroup GitDiffMsg
			au!
			autocmd BufWritePost * call UpdateMark()
		augroup END
	endif
enddef

def Test2()
	#p.Mark()
	#p.Sync()
	prop_remove({ type: 'git-diff-msg-add', all: true})
	prop_remove({ type: 'git-diff-msg-delete', all: true})
enddef
Test2()
#g:Tl = Test2
