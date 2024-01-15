vim9script

def Sink(str: string)
	var i = str->stridx(':') + 2
	exe 'edit ' .. str->slice(i)
enddef

def GetOldFiles()
	exec 'oldfiles'
enddef

def RecentFiles()
	var oldfiles = ''
	redir => oldfiles
	silent call GetOldFiles()
	redir END

	var flist = oldfiles->split('\n')
	call fzf#run(fzf#wrap({'source': flist, 'sink': Sink}))
enddef

export def Setup()
	nmap <silent> <Plug>RecentFiles :call <SID>RecentFiles()<CR>
enddef

