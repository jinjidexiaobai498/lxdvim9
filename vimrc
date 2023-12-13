vim9script
&encoding = 'utf-8'

g:loaded_netrw       = 0
g:loaded_netrwPlugin = 0
import "./plugin.vim" as plugin
import "./basic.vim" as basic
basic.BasicConfig()
plugin.Setup()


# ctlr-p to find all features or go to file "./keymap.vim "
# some key words about features to use in search
# ------------------------------------
# terminal 
# task
# tag
# lsp
# surround
# nerdtree
# fzf
# comment
