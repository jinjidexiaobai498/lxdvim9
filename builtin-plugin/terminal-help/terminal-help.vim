vim9script noclear

import '../../std/terminal.vim' as terminal

var VertShow = () => {
	exe 'vert bo :37 split'
}

var HortShow = () => {
	exe 'rightbelow :14 split'
}

var vert_term = terminal.Terminal.new(VertShow)
var hort_term = terminal.Terminal.new(HortShow)
var hort_term_cwd = terminal.Terminal.new(HortShow, null_function, null_string, true)

var HortTerminalToggle = () => hort_term.Toggle()
var VertTerminalToggle = () => vert_term.Toggle()
var HortTerminalCwdToggle = () => hort_term_cwd.Toggle()

export def Setup()
	nnoremap <Plug>HortTerminalToggle :call <SID>HortTerminalToggle()<cr>
	tnoremap <Plug>HortTerminalToggle <c-\><c-n>:call <SID>HortTerminalToggle()<cr>
	nnoremap <Plug>VertTerminalToggle :call <SID>VertTerminalToggle()<cr>
	tnoremap <Plug>VertTerminalToggle <c-\><c-n>:call <SID>VertTerminalToggle()<cr>
	nnoremap <Plug>HortTerminalCwdToggle :call <SID>HortTerminalCwdToggle()<cr>
	tnoremap <Plug>HortTerminalCwdToggle <c-\><c-n>:call <SID>HortTerminalCwdToggle()<cr>
enddef

