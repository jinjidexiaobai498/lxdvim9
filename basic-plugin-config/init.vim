vim9script

import './FixedTaskList.vim' as ft
import './fzf.vim' as fzf
import './nerdtree.vim' as ndt
import './nerdcommenter.vim' as ndc
import './tagbar.vim' as tg
import './vim-surround.vim' as vsr
import './vim-which-key.vim' as wk
import './git-len.vim' as gitlens

export def Setup()
	ft.Setup()
	fzf.Setup()
	ndt.Setup()
	ndc.Setup()
	tg.Setup()
	vsr.Setup()
	wk.Setup()
	gitlens.Setup()
enddef
