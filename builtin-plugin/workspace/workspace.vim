vim9script

import '../std/global.vim' as G
var debug = true
var Log = G.GetLog(debug)
var info = true
var Info = G.GetLog(info)


const BUF_NAME_PREFIX = '___WorkSpace___'


class WorkSpace
	static ID = 0
	this.map: dict<number> = {}
	this.list: list<any> = []
	def new()
	enddef

endclass

var wk = WorkSpace.new()

def CheckBeforeHandler(bufnr: number): dict<any>
	var bt = getbufvar(bufnr, '&buftype')
	Log('buftype:', bt, 'bufnr:', bufnr)

	if !empty(bt)
		return null_dict
	endif

	var bufinfolist = getbufinfo(bufnr)
	if empty(bufinfolist)
		return null_dict
	endif
	
	return bufinfolist[0]
enddef

def HandlerBufRead(bufnr: number)
	Log(wk)
	Log('BufReadPostHandler')
	var bufinfo = CheckBeforeHandler(bufnr)
	if bufinfo == null_dict
		return
	endif

	if wk.map->has_key(bufinfo.name)
		wk.map[bufinfo.name] = bufinfo.bufnr
		Log('wk.map has store bufinfo.name', bufinfo.name)
		return
	endif

	wk.map[bufinfo.name] = bufinfo.bufnr

enddef

def HandlerBufDelete(bufnr: number)
	Log('BufDeleteHandler')
	var bufinfo = CheckBeforeHandler(bufnr)
	
	Log(bufinfo)

	if !bufinfo
		return
	endif

	Log('type of wk.map', type(wk.map))
	if !has_key(wk.map, bufinfo.name)
		return
	endif

	wk.map->remove(bufinfo.name)
enddef

augroup WorkSpaceReadListenner
	au!
	au BufReadPost * call HandlerBufRead(expand('<abuf>')->str2nr())
	au BufDelete * call HandlerBufDelete(expand('<abuf>')->str2nr())
	au BufWipeout * call HandlerBufDelete(expand('<abuf>')->str2nr())
	# for test easy
	#au BufUnload * call HandlerBufDelete()
augroup END

g:WInfo = funcref(Info, [wk])
