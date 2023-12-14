vim9script

import "./terminal-help/terminal-help.vim" as term

import "./vim-project-session/project-session-list.vim" as psl

import "./colorscheme-selector/colors.vim" as cl

import "./recent-files/recent_file.vim" as rf


export def Setup()
	term.Setup()
	psl.Setup()
	cl.Setup()
	rf.Setup()
enddef


