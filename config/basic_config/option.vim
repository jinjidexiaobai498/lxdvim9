vim9script noclear
export def Setup()
    #in $VIMRUNTIME/defaults.vim to see more default config
    g:mapleader = " "
    g:maplocalleader = ","
    g:netrw_liststyle = 3

    const cache_dir = expand('~/.cache/vim')
    &dir			= expand('~/.cache/vim/swap')
    &undodir		= expand('~/.cache/vim/undo')
    &backupdir		= expand('~/.cache/vim/backup')
    if !isdirectory(cache_dir)  | MkDir(cache_dir)      | endif
    if !isdirectory(&undodir)	| MkDir(&undodir)		| endif
    if !isdirectory(&backupdir) | MkDir(&backupdir)		| endif
    if !isdirectory(&dir)		| MkDir(&dir)			| endif
    set undofile
    set backup
    set viminfo+=n~/.cache/vim/viminfo
    #set statusline=%#IncSearch#\ %2.10{g:StatuslineModeGetter()}\ %<%#DiffChange#\ %m%r%h%w%q\ [%1.10{&ff}]\ [%1.20Y]\ [BUFNR:%1.10{bufnr()}]\ [NROW:%1.10l,NCOL:%1.10v]\ [%1.3p%%]%=%#Type#\ %4.70F\ %#IncSearch#\ %1.20{strftime(\"%Y/%m/%d\ -\ %H:%M\")}
    set statusline=%<%#MoreMsg#%m%r%h%w%q[%1.10{&ff}][%1.20Y]\ [bnr:%1.10{bufnr()}]\ [%1.3p%%][r,c:%1.10l,%1.10v]%=%#Search#\ %4.70F\ %#IncSearch#\ %1.20{strftime(\"%Y/%m/%d\ -\ %H:%M\")}

    filetype plugin indent on
    syntax on
    syntax enable

    set number                          # 显示行号
    set relativenumber                  # 显示相对行号
    set hlsearch                        # 显示搜索匹配字符高亮
    set incsearch                       # 搜索逐字符高亮

    set cursorline                      # 突出显示当前行
    set clipboard^=unnamed,unnamedplus  # 共享剪贴板
    set completeopt=longest,menu        # 打开文件类型检测, 加了这句才可以用智能补全
    set belloff=all                     # 关闭所有提示音
    set termguicolors                   # use guifg and guibg in cterm
    set smartcase                       # 搜索时当只有小写字母时自动开启忽略大小写搜索
    set confirm                         # 在处理未保存或只读文件的时候，弹出确认

    set enc=utf-8                       # 编码设置
    set fileencodings=utf-8,gbk,big5    # 文件编码
    set termencoding=utf-8              # 屏幕显示的编码

    set cindent
    set shiftwidth=4
    set autoindent                      # 自动缩进
    set tabstop=4                       # Tab键的宽度
    set softtabstop=4                   # 统一缩进为4
    set expandtab                       # 不要用空格代替制表符
    set backspace=2                     # 使回格键（backspace）正常处理indent, eol, start等
    set nosmarttab                      # 不在行和段开始处使用制表符
    set nosmartindent                   # 不为C程序提供自动缩进

    # 红色显示行尾部的空格
    match DiffAdd /\s\+$/

    # use 256 colors when possible
    if has('gui_running') || (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256')
        if !has('gui_running') | &t_Co = '256' | endif
        if has('win32') || has('win64')
            set guifont=JetBrainsMono\ Nerd\ Font\ Mono:h14
        elseif has('gui_gtk')
            #set guifont=DejaVu\ Sans\ Mono\ 17
            set guifont=JetBrainsMono\ Nerd\ Font\ Mono\ 16
            set guifontwide=Microsoft\ Yahei\ 17,WenQuanYi\ Zen\ Hei\ 17
        endif
    endif

    # new vim9 features
    if v:version >= 900 | set jumpoptions=stack  | endif
    set history=10000                   # 历史记录数
    set fillchars=vert:\│               # 在被分割的窗口间显示空白，便于阅读

    set mouse=a                         # 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）
    set autoread                        # 设置当文件被改动时自动载入
    set autowrite                       # 自动保存
    set magic                           # 设置魔术
    set ruler                           # 显示光标位置
    set listchars=tab:>-,trail:-

    language en_US.UTF-8
    set langmenu=en.UTF-8
    set helplang=en

    set scrolloff=5                     # 总是和最底部或者顶部距离4行
    set laststatus=2                    # 总是显示状态行
    set cmdheight=1                     # 命令行（在状态行下）的高度，默认为1，这里是2
    #set iskeyword+=_,$,@,%,#,-          # 带有如下符号的单词不要被换行分割
    set linespace=0                     # 字符间插入的像素行数目
    set wildmenu                        # 增强模式中的命令行自动完成操作
    set selectmode=mouse,key            # 使用鼠标和normal模式下的 v, V, <C-v>来选择范围
    set report=0                        # 通过使用: commands命令，告诉我们文件的哪一行被改变过
    set showmatch                       # 高亮显示匹配的括号
    set matchtime=1                     # 匹配括号高亮的时间（单位是十分之一秒）

    #set noeb                            # 去掉输入错误的提示声音
    #set whichwrap+=<,>,[,]              # 允许backspace和光标键跨越行边界
    #set makeprg=g++\ -Wall\ \ %         # make 运行
    #set foldenable                      # 开始折叠
    #set foldmethod=indent		         # 利用缩进折叠代码
    #set foldcolumn=0
    #set foldlevel=4
enddef

def MkDir(path: string)
    if !mkdir(path, 'p') | throw 'make direcotry ' .. path .. 'failed' | endif
enddef
