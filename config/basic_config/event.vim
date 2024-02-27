vim9script

var YOUR_NAME = get(g:, 'AuthorName', 'xxx')
var YOUR_BLOG = get(g:, 'AuthorBlog', 'xxx')
var TIME_FORMAT = get(g:, 'AuthorTimeFormat', '%Y 年 %b %d日 %X')

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

const BASHES_MAP = {'sh': true, 'bash': true, 'zsh': true}
def SetTitle()
	var ext = expand('%:e')
	lnum = 1

	if BASHES_MAP->has_key(ext)
		Append( "#!" .. &shell)
		NormalTitle('#')
	elseif ext == 'cpp'
		NormalTitle('//')
		Append( '#include <iostream>')
		Append( '#include <vector>')
		Append( '#include <string>')
		Append( '#include <algorithm>')
		Append( '#include <unordered_set>')
		Append( '#include <unordered_map>')
		Append( '#include <set>')
		Append( '#include <map>')
		Append( '#include <deque>')
		Append( 'using namespace std;')
		Append( 'int main()')
		Append( '{')
		Append( '	cout<<"hello wolrd!";')
		Append( '}')
	elseif ext == 'c'
		NormalTitle('//')
		Append('#include <stdio.h>')
		Append('#include <math.h>')
		Append('#include <string.h>')
		Append('int main()')
		Append( '{')
		Append( '	printf("hello wolrd!");')
		Append( '}')
	elseif ext == 'py'
		Append('#!/bin/python3')
		NormalTitle('#')
		Append('if __name__ == "__main__":')
		Append('	print("hello world!")')
	else
		NormalTitle()
	endif

enddef

export def Setup()
	augroup BasicEvent
		au!
		au BufWritePost .vimrc,vimrc,_vimrc exe "so %"
		au BufNewFile *.py,*.cc,*.sh,*.zsh,*.bash,*.java,*.cpp,*.c SetTitle()
        au ColorScheme * hi VertSplit None | hi SignColumn None
	augroup END
enddef

