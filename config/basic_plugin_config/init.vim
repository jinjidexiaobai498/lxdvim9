vim9script

import './FixedTaskList.vim' as FixedTaskList
import './nerdtree.vim' as nerdtree
import './nerdcommenter.vim' as nerdcommenter
import './tagbar.vim' as tagbar
import './vim-surround.vim' as vim_surround
import './vim-which-key.vim' as vim_which_key
import './fzf.vim' as fzf

export def Setup()
    FixedTaskList.Setup()
    nerdtree.Setup()
    nerdcommenter.Setup()
    tagbar.Setup()
    vim_surround.Setup()
    vim_which_key.Setup()
    fzf.Setup()
enddef
