vim9script

import '../std/global.vim' as G
import '../std/file.vim' as file
export var debug = false

var Log = G.GetLog(debug)

def Sink(str: string)
	Log('str:', str)
	var start = str->stridx(' ') + 1
	var end = str->stridx('(')

	Log('index of start of function name', start)
	Log(str->slice(start, end))

	var view = ''

	redir => view 
	exe 'verbose function ' .. str->slice(start, end)
	redir END

	var content = view->split('\n')
	Log(content)

	var winid = popup_dialog(content, {
		filter: 'popup_filter_menu',
		padding: [2, 4, 2, 4],
	})
	win_execute(winid, 'set cursorline')

enddef

def GetFunctions()
	exec 'function'
enddef

def Functions()
	var functions = ''
	redir => functions
	silent call GetFunctions()
	redir END

	var flist = functions->split('\n')
	Log(flist->string())

	call fzf#run(fzf#wrap({'source': flist, 'sink': Sink}, 1))
enddef

export def Setup()
	nmap <silent> <Plug>FZFFunctions :call <SID>Functions()<CR>
	command Functions call <SID>Functions()
enddef

#Functions()
