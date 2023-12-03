vim9script
def! g:Stl_mode(): string
	var a = mode()
	if a == 'n'
		a = "NORMAL"
	elseif a == 'c'
		a = "CMD"
	elseif a == 'v' || a == 'V'
		a = "VISIUAL"
	elseif a == 'i'
		a = "INSERT"
	endif
	return a
enddef

#################### options####################
export def BasicOptionConfig()

	g:mapleader = " "
	g:maplocalleader = " "
	g:netrw_liststyle = 3

	# use 256 colors when possible
	if has('gui_running') || (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256')
		if !has('gui_running')
			&t_Co = '256'
		endif
		set guifont=JetBrainsMono_Nerd_Font_Mono:h14
	endif

	&undodir = expand('~') .. "/.cache/vim/undo"
	&backupdir = expand('~') ..  "/.cache/vim/backup"
	&dir =  expand('~') .. "/.cache/vim/swap"

	if !isdirectory(&dir)
		assert_true(mkdir(&dir, 'p', 0o755))
	endif

	if !isdirectory(&backupdir)
		assert_true(mkdir(&backupdir, 'p', 0o755))
	endif

	if !isdirectory(&dir)
		assert_true(mkdir(&dir, 'p', 0o755))
	endif

	set undofile
	set backup
	set viminfo+=n~/.vim/dirs/viminfo

	set fileencodings=utf-8,gbk,big5
	set scrolloff=4 # 光标移动到buffer的顶部和底部时保持3行距离

	set mouse=a # 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）

	set termguicolors

	#设置透明背景
	highlight Normal ctermbg=none
	highlight NonText ctermbg=none

	set statusline=%7{g:Stl_mode()}\ [%4.20F]\ %m%r%h%w%q\ [%4.10{&ff}]\ [%4.20Y]\ %=[NROW:%4l,NCOL:%4v][%3p%%]\ %20{strftime(\"%d/%m/%y\ -\ %H:%M\")}

	set nocompatible #不要使用vi的键盘模式，而是vim自己的
	filetype on # 侦测文件类型
	filetype plugin indent on 
	syntax on
	syntax enable
	colorscheme default

	set autoread # 设置当文件被改动时自动载入
	set completeopt=preview,menu  #代码补全 
	set clipboard=unnamedplus  #共享剪贴板  
	set autowrite #自动保存
	set ruler                   # 打开状态栏标尺
	#set makeprg=g++\ -Wall\ \ % #make 运行
	#set nocursorline              # 突出显示当前行
	#set cursorline              # 突出显示当前行
	set magic                   # 设置魔术
	set foldcolumn=0
	set foldmethod=indent		#利用缩进折叠代码 
	set foldlevel=3 
	set foldenable              # 开始折叠
	set noeb # 去掉输入错误的提示声音
	set confirm # 在处理未保存或只读文件的时候，弹出确认

	set autoindent # 自动缩进
	set cindent
	set tabstop=4 # Tab键的宽度
	set softtabstop=4 # 统一缩进为4
	set shiftwidth=4
	set noexpandtab # 不要用空格代替制表符
	set smarttab # 在行和段开始处使用制表符
	set backspace=2 # 使回格键（backspace）正常处理indent, eol, start等
	set smartindent # 为C程序提供自动缩进

	set number # 显示行号
	set history=10000 # 历史记录数
	set ignorecase #搜索忽略大小写
	set hlsearch 
	#set incsearch #搜索逐字符高亮

	set enc=utf-8 #编码设置
	set termencoding=utf-8 #屏幕显示的编码
	set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
	set langmenu=en
	set helplang=cn

	#set statusline=[%F]%y%r%m%*%=[Line:%l/%L,Column:%c][%p%%]
	set laststatus=2 # 总是显示状态行
	set cmdheight=2 # 命令行（在状态行下）的高度，默认为1，这里是2
	set iskeyword+=_,$,@,%,#,- # 带有如下符号的单词不要被换行分割
	set linespace=0 # 字符间插入的像素行数目
	set wildmenu # 增强模式中的命令行自动完成操作
	#set whichwrap+=<,>,h,l # 允许backspace和光标键跨越行边界

	set selection=exclusive
	set selectmode=mouse,key

	set report=0 # 通过使用: commands命令，告诉我们文件的哪一行被改变过

	set fillchars=vert:\ ,stl:\ ,stlnc:\  # 在被分割的窗口间显示空白，便于阅读

	set showmatch # 高亮显示匹配的括号
	set completeopt=longest,menu #打开文件类型检测, 加了这句才可以用智能补全

	#set matchtime=1 " 匹配括号高亮的时间（单位是十分之一秒）

enddef

