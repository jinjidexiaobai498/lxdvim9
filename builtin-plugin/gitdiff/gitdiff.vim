vim9script

import '../std/project.vim' as P
import '../std/global.vim' as G
const __FILE__ = expand('<sfile>:p')
var debug = true
var Log = G.GetLog(debug, __FILE__)
var Info = G.GetLog(true, __FILE__)

export class GitDiffMsg
	this.is_init = true
	this.msglist: list<string>
	this.msg: string
	this.command: string

	def GetStatus()
		return this.is_init
	enddef

	def new()
		var filename = expand('%:p')
		var dirname = expand('%:p:h')
		this.command = [ 'git',  '-C', dirname, 'diff', 'HEAD', '--', filename]->join(' ')
		Log('command :', this.command)
		this.msglist = systemlist(this.command .. ' || echo $?')
		if this.msglist[-1] != '0'
			Info('use git error, check this file is not in git charge', this.command)
			this.is_init = false
			return
		endif
		Log('git diff msg', this.msg)
	enddef


endclass

def Test()
	#var p = GitDiffMsg.new()
	
	const type_name = 'git-diff-msg'
	if empty(prop_type_get(type_name))
		prop_type_add(type_name, {highlight: 'Comment'})
	endif

	prop_remove({ type: type_name})
	prop_add(37, 1, { type: type_name, text: '+', })

enddef
Test()

