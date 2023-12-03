vim9script noclear
import "./terminal-help.vim" as t

export def Setup()
	g:hort_term = t.Terminal.new()
	g:vert_term = t.Terminal.new("vert bo", 37)
	nnoremap <c-t> :call <SID>t.TerminalToggle(g:hort_term)<cr>
	tnoremap <c-t> <c-\><c-n>:call <SID>t.TerminalToggle(g:hort_term)<cr>
	nnoremap <c-\> :call <SID>t.TerminalToggle(g:vert_term)<cr>
	tnoremap <c-\> <c-\><c-n>:call <SID>t.TerminalToggle(g:vert_term)<cr>
enddef

