vim9script
export const DATA_DIR = expand("~/.vim")
export const HOME_CONFIG_DIR = expand("~/.config")
export const SELF_PATH = expand('<sfile>:p:h:h')
export var debug = false

export def Debug(...msgs: list<any>)
	if !debug
		return
	endif
	echom Args(msgs)
enddef

export def GetAssertTrue(error: string): func
	return funcref(AssertTrueDefine, [error])->copy()
enddef

export def GetAssertFalse(error: string): func
	return funcref(AssertFalseDefine, [error])->copy()
enddef

export def AssertFalseDefine(error: string, expr: bool, ...msgs: list<any>)
	if expr
		echom Args(msgs)
		throw error
	endif
enddef


export def AssertTrueDefine(error: string, expr: bool, ...msgs: list<any>)
	if !expr
		echom Args(msgs)
		throw error
	endif
enddef

export def AssertTrue(expr: bool, ...msgs: list<any>)
	echom Args(msgs)
	throw 'UserPlugin'
enddef

export def CntArgs(...msgs: list<any>): string
	return join(msgs)
	#var s = ''
	#for i in msgs
		#s ..= ' '
		#if type(i) != 1
			#s ..= i->string()
		#else
			#s ..= i
		#endif
	#endfor
	#return s
enddef


export def Args(msgs: list<any>): string
	return join(msgs)

	#var s = ''
	#for i in msgs
		#s ..= ' '
		#if type(i) != 1
			#s ..= i->string()
		#else
			#s ..= i
		#endif
	#endfor
	#return s
enddef

export def FlagInfo(flag: bool, ...msgs: list<string>)
	if !flag
		return
	endif
	echom Args(msgs)
enddef

export def Info(...msgs: list<string>)
	echom Args(msgs)
enddef

export def GetInfo(flag: bool, ...pre_msgs: list<any>): func
	return funcref(FlagInfo, [flag, pre_msgs])->copy()
enddef

export def GetLog(flag: bool, ...pre_msgs: list<any>): func
	return funcref(FlagLog, [flag, pre_msgs])->copy()
enddef

def FlagLog(flag: bool, ...msgs: list<any>)
	if !flag
		return
	endif
	echom Args(msgs)
enddef

export def Log(...msgs: list<any>)
	if !debug
		return
	endif
	echom Args(msgs)
enddef

export def CloseNerdTree()
	for buf in getbufinfo({'bufloaded': 1})
		if buf.name =~ 'NERD_tree'
			Log('buf: ', buf->string())
			if !empty(buf.windows)
				exe 'NERDTreeToggle'
				exe 'bwipeout ' .. buf.bufnr
			endif
		endif
	endfor
enddef

export var SHELL_LIST = ['/bin/zsh', '/bin/bash', '/bin/sh']
export def GetShell(): string
	for s in SHELL_LIST
		if executable(s)		
			return s->copy() 
		endif
	endfor
	return &shell
enddef

export def OR(...obs: list<any>): any
	for i in obs
		if !(!(i))
			return i
		endif
	endfor
	return null
enddef

#Log('SELF_PATH:', SELF_PATH)
