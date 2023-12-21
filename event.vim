vim9script

var YOUR_NAME = get(g:, 'AuthorName', 'xxx')
var YOUR_BLOG = get(g:, 'AuthorBlog', 'xxx')
var TIME_FORMAT = get(g:, 'AuthorTimeFormat', '%Y 年 %b %d日 %X')

const BASHES = {'sh': true, 'bash': true, 'zsh': true}

var lnum = 1

def Append(str: string)
	lnum = (lnum > 0 ? lnum : 1)
	setline(lnum, str)
	lnum += 1
enddef

def NormalTitle(comment: string = '//')
	Append(comment .. "Author: " .. YOUR_NAME)
	Append(comment .. "Time: " .. strftime(TIME_FORMAT))
	Append(comment .. "Blog: " .. YOUR_BLOG)
	Append(comment .. "FileName: " .. expand('%:p'))
enddef

# 定义函数SetTitle，自动插入文件头"
def SetTitle()
	var ext = expand('%:e')
	lnum = 1

	if BASHES->has_key(ext)
		Append( "#!" .. &shell)
		NormalTitle('#')
	elseif ext == 'cpp'
		NormalTitle('//')
		Append( '#include <iostream>')
		Append( '#include <vector>')
		Append( '#include <algorithm>')
		Append( 'using namespace std;')
		Append( 'int main()')
		Append( '{')
		Append( '	cout<<"hello wolrd!";')
		Append( '}')
	elseif ext == 'c'
		NormalTitle('//')
		Append('#include <stdio.h>')
		Append('int main()')
		Append( '{')
		Append( '	printf("hello wolrd!");')
		Append( '}')
	else
		NormalTitle()
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
		autocmd BufNewFile *.py,*.cc,*.sh,*.zsh,*.bash,*.java,*.cpp,*.c SetTitle()
	augroup END

enddef

