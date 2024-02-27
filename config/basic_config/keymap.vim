vim9script
var CloseOtherBuffers = null_function
var SaveOnNormalFile = null_function
var Lazygit = null_function
export def Setup()
	inoremap jk <Esc>
	tnoremap <C-q> <C-\><C-n>
	#tnoremap jk <C-\><C-n>

	# 回车即选中当前项
	inoremap <expr> <CR>	pumvisible() ? "\<C-y>" : "\<CR>"
	inoremap <expr> <Tab>	pumvisible() ? "\<C-y>" : "\<Tab>"

	PairMatch()
    nnoremap ,r :browse oldfiles<CR>
	nnoremap <F5> <ScriptCmd>RunCode()<CR>
    nnoremap <leader>ee <Cmd>e $MYVIMRC<cr>

    CloseOtherBuffers = () => {
        var cbufnr = bufnr()
        for bufcontent in getbufinfo()
            if cbufnr == bufcontent.bufnr || !empty(getbufvar(bufcontent.bufnr, '&bt')) | continue | endif
            silent exe "bwipeout " .. bufcontent.bufnr
        endfor
    }
    nnoremap <leader>co <ScriptCmd>CloseOtherBuffers()<CR>

    nnoremap ]b <Cmd>bnext<CR>
    nnoremap [b <Cmd>bpre<CR>
    nnoremap ]t <Cmd>tabnext<CR>
    nnoremap [t <Cmd>tabpre<CR>
    nnoremap <silent> <A-q> <Cmd>close!<CR>
    nnoremap <silent> <A-s> <Cmd>w !sudo tee "%"<CR>
    nnoremap <silent> <c-q> <Cmd>%bwipeout<CR>:qa<CR>
    SaveOnNormalFile = () => {
        if empty(getbufvar(bufnr(), '&bt')) | exe "write" | endif
    }
    nnoremap <silent> <c-s> <ScriptCmd>SaveOnNormalFile()<CR>

    nnoremap <leader>b <Cmd>buffers<CR>:b
    nnoremap <leader>w <Cmd>b#<CR>
    nnoremap <leader>q <Cmd>close<CR>
    # 红色显示行尾部的空格
    nnoremap <leader>m <Cmd>match DiffAdd /\s\+$/<CR>

    if get(g:, 'use_emacs_insert_mode_keymap_binding', true)
        ToggleEmascInsertKeymapBinding(true)
        command! ToggleEmascInsertKeymapBinding ToggleEmascInsertKeymapBinding()
        nnoremap <leader>ek <ScriptCmd>ToggleEmascInsertKeymapBinding()<CR>
    endif

    if executable('lazygit')
        if has('win32') || has('win64')
            Lazygit = () => {
                lcd %:h
                !lazygit
            }
        else
            Lazygit = () => popup_create(term_start('lazygit', {hidden: 1, term_finish: 'close', cwd: expand("%:h")}), {minwidth: 200, minheight: 60})
        endif
        nmap ,g <ScriptCmd>Lazygit()<CR>
    endif

enddef

var DeleteNextChar = null_function
var DeleteNextString = null_function
var ToggleFlag = false
def ToggleEmascInsertKeymapBinding(flag = false)
    if flag && ToggleFlag | return | endif
    if ToggleFlag
        iunmap <C-a>
        iunmap <C-e>
        iunmap <C-f>
        iunmap <C-b>
        iunmap <C-l>
        iunmap <C-d>
        iunmap <C-k>
    else
        inoremap <A-o> <ESC>o
        inoremap <A-O> <ESC>O
        inoremap <A-l> <ESC>la
        inoremap <A-h> <ESC>ha
        inoremap <A-j> <ESC>ja
        inoremap <A-k> <ESC>ka
        inoremap <A-d> <ESC>S
        inoremap <A-b> <ESC>ba
        inoremap <A-f> <ESC>wa

        inoremap <c-a> <Esc>I
        inoremap <c-e> <Esc>A
        inoremap <c-f> <Right>
        inoremap <c-b> <Left>
        inoremap <c-z> <ESC>ua
        inoremap <c-y> <ESC><c-r>

        if !DeleteNextChar || !DeleteNextString
            var DeleteNext = (normal_command) => {
                var pos = col('.')
                if		pos == col('$') - 1	| return
                elseif	pos == 1			| exe $"normal! {normal_command}"
                else						| exe $"normal! l{normal_command}"
                endif
            }
            DeleteNextChar    = () => DeleteNext('x')
            DeleteNextString  = () => DeleteNext('d$')
            inoremap <c-l> <Esc><ScriptCmd>DeleteNextChar()<CR>i
            inoremap <c-d> <Esc><ScriptCmd>DeleteNextChar()<CR>i
            inoremap <c-k> <Esc><ScriptCmd>DeleteNextString()<CR>a
        endif
    endif
    ToggleFlag = !ToggleFlag
enddef

const BASHES_MAP = {'sh': true, 'bash': true, 'zsh': true}
const EXT = ((has('win32') || has('win64')) ? '.exe' : '.out')
def RunCode()
    if	    &ft == 'vim'				| exe 'source %'
    elseif	&ft == 'rust'				| exe '!cargo run'
    elseif  &ft == 'java'               | exe "!java %"
    elseif BASHES_MAP->has_key(&ft)		| exe $"!. {expand('%')}"
    else
        var file    = expand('%')
        var output  = expand('%:r')
        if		&ft == 'cpp'	| exe $'!g++ -g -O2 -Wall {file} -o {output} && {output}.{EXT}'
        elseif	&ft == 'c'		| exe $'!gcc -g -O2 -Wall {file} -o {output} && {output}.{EXT}'
        endif
    endif
enddef

var ClosePair = null_function
def PairMatch()
    ClosePair = (char) => {
        if getline('.')[col('.') - 1] == char	| return "\<Right>"
        else									| return char
        endif
    }
    inoremap ( ()<ESC>i
    inoremap ) <c-r>=<SID>ClosePair(')')<CR>
    inoremap { {}<ESC>i
    inoremap } <c-r>=<SID>ClosePair('}')<CR>
    inoremap [ []<ESC>i
    inoremap ] <c-r>=<SID>ClosePair(']')<CR>
    inoremap " ""<ESC>i
    inoremap ' ''<ESC>i
enddef
