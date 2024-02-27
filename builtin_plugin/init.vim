vim9script
import "./terminal_help.vim" as terminal_help
import "./gitdiff.vim" as gitdiff
import "./workspace.vim" as workspace
import "./lxdfzf.vim" as lxdfzf

export def Setup()
    terminal_help.Setup()
    gitdiff.Setup()
    workspace.Setup()
    lxdfzf.Setup()
enddef
