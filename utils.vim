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


import './global.vim' as G
def Test()
	var LLog = GetLog(true)
	LLog("vim_plug_path: ", G.VIM_PLUG_PATH)
	LLog("vim_data_path: ", G.VIM_DATA_PATH)
enddef


#Test()
