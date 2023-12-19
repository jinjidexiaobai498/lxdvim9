vim9script noclear

import '../std/terminal.vim' as terminal

var VertShow = () => {
	exe 'vert bo :37 split'
}

var HortShow = () => {
	exe 'rightbelow :14 split'
}

var vert_term = terminal.Terminal.new(VertShow)
var hort_term = terminal.Terminal.new(HortShow)

def HortTerminalToggle()
	hort_term.Toggle()
enddef

def VertTerminalToggle()
	vert_term.Toggle()
enddef

export def Setup()
	nnoremap <Plug>HortTerminalToggle :call <SID>HortTerminalToggle()<cr>
	tnoremap <Plug>HortTerminalToggle <c-\><c-n>:call <SID>HortTerminalToggle()<cr>
	nnoremap <Plug>VertTerminalToggle :call <SID>VertTerminalToggle()<cr>
	tnoremap <Plug>VertTerminalToggle <c-\><c-n>:call <SID>VertTerminalToggle()<cr>
enddef

