vim9script
import './constant.vim' as C
export const UseWindows = has('win32') || has('win64')
export const Backslash = UseWindows ? '\' : '/'
export const DATA_DIR = expand("~/.vim")
export const HOME_CONFIG_DIR = expand("~/.config")
export const SELF_PATH = expand('<sfile>:p:h:h')
export const TAB = '    '
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
enddef


export def Args(msgs: list<any>): string
	return join(msgs)
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
export const SEHLL = GetShell()

export def OR(...obs: list<any>): any
	for i in obs
		if !(!(i))
			return i
		endif
	endfor
	return null
enddef

export def GetParentPath(path: string): string
	var last_index = path->strridx(Backslash)

	if last_index == 0 
		return null_string 
	endif

	return path[ : last_index - 1]
enddef

export def ToString(obj: any): string
	var _t = type(obj)

	if _t == 1
		return obj
	endif

	return obj->string()
enddef

def IndentString(str: string, tabnum: number = 1): string
	var res = ''
	if tabnum > 0
		res ..= TAB->repeat(tabnum)
	endif
	res ..= str
	return res
enddef

export def IndentStringln(str: string, tabnum: number = 1): string
	return IndentString(str .. "\n", tabnum)
enddef

export def CurString(str: string, tabnum: number = 1): string
	return IndentString(str, tabnum - 1)
enddef

export def CurStringln(str: string, tabnum: number = 1): string
	return IndentStringln(str, tabnum - 1)
enddef

export def Inspect(obj: any, tabnum: number = 1, last_type = -1): string
	var res = ''
	var t = type(obj)
	if t == C.TYPE.Dict
		if len(obj) == 0
			return Inspect('{}', tabnum + 1, t)
		endif
		res ..= "\n"
		res ..= CurStringln('{', tabnum)
		for i in keys(obj)
			res ..= CurString(ToString(i) .. " : ", tabnum)
			res ..= Inspect(obj[i], tabnum + 1, t)  .. ",\n"
		endfor
		res ..= CurString('}', tabnum)

	elseif t == C.TYPE.List
		if len(obj) == 0 
			return Inspect('[]', tabnum + 1, t)
		endif
		res ..= "\n"

		res ..= CurStringln('[', tabnum)
		for i in obj
			res ..= Inspect(i, tabnum + 1, t)  .. ",\n"
		endfor
		res ..= CurString(']', tabnum)
	else
		if last_type == C.TYPE.Dict
			return ToString(obj)
		else
			return CurString(ToString(obj), tabnum)
		endif
	endif
	return res
enddef

export def Print(obj: any, tabnum: number = 1)
	echo Inspect(obj, tabnum)
enddef
