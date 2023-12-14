vim9script
###################events#####################

#定义函数SetTitle，自动插入文件头"
def SetTitle()
	if expand ("%:e") == 'sh'
		call setline(1, "#!/bin/bash")
		call setline(2, "#Author:LvXudong")
		call setline(3, "#Time:".strftime("%Y 年 %b %d日 %X"))
		call setline(4, "#Name:".expand("%"))
		call setline(5, "#Version:V1.0")
		call setline(6, "#Description:This is a production script.")
	elseif expand ("%:e") == 'cpp' || expand ("%:e") == 'c' 
		call setline(1, "//Author:LvXuDong")
		call setline(2, "//Blog:lxd_ls")
		call setline(3, "//Time:".strftime("%Y 年 %b %d日 %X"))
		call setline(4, "//Name:".expand("%")) 

	else
		call setline(1, "//Author:LvXuDong")
		call setline(2, "//Blog:lxd_ls")
		call setline(3, "//Time:".strftime("%Y 年 %b %d日 %X"))
		call setline(4, "//Name:".expand("%")) 
	endif

enddef
#在shell脚本开头自动增加解释器以及作者等版权信息
#新建.py,.cc,.sh,.java文件，自动插入文件头"
export def Setup()

	augroup EditVimrc
		autocmd!
		au BufWritePost .vimrc,vimrc,vimrc9 exe "so %"
	augroup END

	augroup SetTitle
		au!
		autocmd BufNewFile *.py,*.cc,*.sh,*.java,*.cpp,*.c exec call SetTitle()
	augroup END

enddef

