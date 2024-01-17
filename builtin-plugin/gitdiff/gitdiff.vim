vim9script

import '../../std/global.vim' as G
const __FILE__ = expand('<sfile>:p')
var debug = false
var Log = G.GetLog(debug)
var Info = G.GetLog(true, __FILE__)
export class GitDiffMsg
	
	this.changedtick = 0
	this.bufnr: number = -1
	this.command: string
	this.msglist: list<string>
	this.is_useful = true

	def Sync(): bool
		var bnr = bufnr()
		var changedtick = getbufvar(bnr, 'changedtick')

		if bnr == this.bufnr && changedtick == this.changedtick | return true | endif

		if !empty(getbufvar(bnr, '&bt')) 
			Info("this buffer is not normal file, we don't do git diff")
			return false 
		endif
		this.command = GetCommand()
		this.msglist = systemlist(this.command .. ' ; echo $?')
		this.is_useful = this.msglist[-1] == '0'
		this.msglist->remove(-1)
		this.bufnr = bnr
		this.changedtick = changedtick
		Log('command:', this.command)
		return true
		#G.Print(this.msglist)
		#echo G.Inspect(this.msglist)
	enddef

	def Render()
		if !this.Sync() | return | endif
		if !this.is_useful
			Log('In command', this.command)
			Log('Error ! Current buffer is not charged by git , please create a git project')
			return
		endif
		Mark(this.msglist, this.bufnr)
	enddef

endclass

def IsStartLine(str: string): bool
	return str->match('^@@ -[0-9]*,[0-9]* +[0-9]*,[0-9]* @@') == 0
enddef

def GetStartLineMatchList(str: string): list<number>
	var res_str = (str->matchlist('^@@ -\([0-9]*\),\([0-9]*\) +\([0-9]*\),\([0-9]*\) @@'))
	if empty(res_str) | return null_list | endif
	var res: list<number> = []
	for s in res_str | res->add(str2nr(s)) | endfor
	return res->slice(1, 5)
enddef

const AddSignId					= 100
const DeleteSignId				= 101
const ChangedSignId				= 102
const ChangedAndDeleteSignId	= 103
const SignZindex				= 11
const GitSignGroup				= 'LxdGitDiff'
const GroupSignID = 1
var is_register = false
def ConfigSign()
	if is_register | return | endif
	is_register = true
	hi LxdGitDiffAdd term=bold ctermfg=Green  guifg=#00ff00
	hi LxdGitDiffDelete term=bold ctermfg=1 guifg=#ff0000
	hi LxdGitDiffChanged term=bold ctermfg=11 guifg=#fab005
	hi LxdGitDiffChangedAndDelete term=bold ctermfg=173 guifg=#d7875f
	# '┃' = <c-k>VV ; '⊥' = <c-k>-T ; '‾' = <c-k>'-
	sign_define('LxdGitDiffAdd', {text: "┃", texthl: 'LxdGitDiffAdd'})
	sign_define('LxdGitDiffDelete', {text: "‾", texthl: 'LxdGitDiffDelete'}) 
	sign_define('LxdGitDiffChanged', {text: "┃", texthl: 'LxdGitDiffChanged'})
	sign_define('LxdGitDiffChangedAndDelete', {text: '⊥', texthl: 'LxdGitDiffChangedAndDelete'})
enddef

var commandlist = ['git -C', ' ', 'diff HEAD --', ' ']
def GetCommand(): string
	commandlist[1] = expand('%:p:h')
	commandlist[3] = expand('%:p')
	return commandlist->join(' ')
enddef

def Clear(bufnumber: number)
	sign_unplace(GitSignGroup, {buffer: bufnumber})
enddef
def MarkAdd(line_number: number, bufnr: number)
	sign_place(AddSignId, GitSignGroup, 'LxdGitDiffAdd', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkDelete(line_number: number, bufnr: number)
	sign_place(DeleteSignId, GitSignGroup, 'LxdGitDiffDelete', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkChanged(line_number: number, bufnr: number)
	sign_place(ChangedSignId, GitSignGroup, 'LxdGitDiffChanged', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkChangedAndDelete(line_number: number, bufnr: number)
	sign_place(ChangedAndDeleteSignId, GitSignGroup, 'LxdGitDiffChangedAndDelete', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def Mark(msg_list: list<string>, bufnr: number)
	ConfigSign()
	Clear(bufnr)
	var LEN = len(msg_list)
	Log('LEN: ', LEN)

	var li = 0
	while li < LEN
		var sml = GetStartLineMatchList(msg_list[li])
		++li

		if sml == null_list | continue | endif

		Log('sml', sml)
		#echo 'sml' sml
		var sum_lines_off = sml[3]
		var count = 0
		while count < sum_lines_off && li < LEN
			var cnt_delete = 0
			var first_char = empty(msg_list[li]) ? ' ' : msg_list[li][0]

			Log('first_char', first_char)
			Log('li:', li)
			if count < sum_lines_off
				while first_char == ' '
					Log('line:', msg_list[li])
					++li
					++count
					if li >= LEN || count >= sum_lines_off | break | endif
					first_char = empty(msg_list[li]) ? ' ' : msg_list[li][0]
				endwhile
			endif
			Log('li:', li)

			var startl = sml[2] + count

			while first_char == '-'
				Log('line:', msg_list[li])
				++cnt_delete
				++li
				if li >= LEN | break | endif
				first_char = empty(msg_list[li]) ? ' ' : msg_list[li][0]
			endwhile
			Log('li:', li)

			var cnt_add = 0
			while first_char == '+' && li < LEN
				Log('line:', msg_list[li])
				++cnt_add
				++li
				++count
				if count >= sum_lines_off || li >= LEN | break | endif
				first_char = empty(msg_list[li]) ? ' ' : msg_list[li][0]
			endwhile

			# mark all cnt add and delete
			#echo 'startl' startl
			if cnt_add > 0
				if cnt_delete <= cnt_add
					for i in range(cnt_delete)
						MarkChanged(i + startl, bufnr)
					endfor
					for i in range(cnt_delete, cnt_add - 1)
						MarkAdd(i + startl, bufnr)
					endfor
				else
					for i in range(cnt_add - 1)
						MarkChanged(i + startl, bufnr)
					endfor
					MarkChangedAndDelete(cnt_add + startl - 1, bufnr)
				endif
			elseif cnt_delete > 0
				MarkDelete(startl, bufnr)
			endif

		endwhile
	endwhile
enddef


var lxdgit = GitDiffMsg.new()
var Run = () => lxdgit.Render()

var toggle_flag = false
export def DisableGitDiffMark()
	sign_unplace(GitSignGroup)
	augroup LxdGitDiffMsg
		au!
	augroup END
	toggle_flag = false
enddef

export def EnableGitDiffMark()
	augroup LxdGitDiffMsg
		au!
		autocmd BufWritePost * call Run()
	augroup END
	Run()
	toggle_flag = true
enddef

export def ToggleGitDiffMark()
	if toggle_flag
		DisableGitDiffMark()
	else
		EnableGitDiffMark()
	endif
enddef

export def Setup()
	augroup LxdGitDiffMsg
		au!
		autocmd BufWritePost * call Run()
	augroup END
	nmap <Plug>ToggleLxdGitDiffMark :call <SID>ToggleGitDiffMark()<CR>
	command! ToggleGitDiffMark call <SID>ToggleGitDiffMark()
enddef

def Test()
	Setup()
enddef
def Test2()
	Clear(1)
enddef
#Test()
#g:Tl = Test2
