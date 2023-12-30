vim9script

import "./terminal-help/terminal-help.vim" as terminal_help

import "./vim-project-session/project-session-list.vim" as project

import "./colorscheme-selector/colors.vim" as colors_selector

import "./recent-files/recent_file.vim" as recent_file

import "./fzf-functions/functions.vim" as functions

import "./gitdiff/gitdiff.vim" as gitdiff


export def Setup()
	terminal_help.Setup()
	project.Setup()
	colors_selector.Setup()
	recent_file.Setup()
	functions.Setup()
	gitdiff.Setup()
enddef


