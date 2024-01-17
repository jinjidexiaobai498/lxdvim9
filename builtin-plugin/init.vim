vim9script

import "./terminal-help/terminal-help.vim" as terminal_help

import "./vim-project-session/project-session-list.vim" as project

import "./colorscheme-selector/colors.vim" as colors_selector

import "./fzf-recentfiles/recentfiles.vim" as recentfiles

import "./fzf-functions/functions.vim" as functions

import "./gitdiff/gitdiff.vim" as gitdiff

import "./netrw/netrw_toggle.vim" as netrw_toggle

export def Setup()
	terminal_help.Setup()
	project.Setup()
	colors_selector.Setup()
	recentfiles.Setup()
	functions.Setup()
	gitdiff.Setup()
	netrw_toggle.Setup()
enddef


