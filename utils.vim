vim9script

export var debug = false

export def EInfo(flag: bool, ...msgs: list<string>)
	var s = ''
	for i in msgs
		s ..= i
	endfor
	echom s
enddef

export def Info(...msgs: list<string>)
	var s = ''
	for i in msgs
		s ..= i
	endfor
	echom s
enddef

export def GetInfo(flag: bool): func
	return funcref(EInfo, [flag])->copy()
enddef

export def GetLog(flag: bool): func
	return funcref(ELog, [flag])->copy()
enddef

def ELog(flag: bool, ...msgs: list<any>)
	if !flag
		return
	endif
	var s = ''
	for i in msgs
		s ..= i->string()
	endfor
	echom s
enddef


export def Log(...msgs: list<any>)
	if !debug
		return
	endif
	var s = ''
	for i in msgs
		s ..= i->string()
	endfor
	echom s
enddef

