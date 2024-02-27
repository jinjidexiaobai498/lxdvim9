vim9script
import "./std/shell_session.vim" as async_shell_session
const HashCodeLen = 10
var colorscheme_buffer = '1'
export class GitDiffMsg
    var bufnr = -1
    var changedtick = 0
    var buffer_hashcode = "-1"
    var is_useful = false
    def Render()
        var bnr = bufnr()
        var changedtick = getbufvar(bnr, 'changedtick')
        if bnr != this.bufnr
            if empty(bufname(bnr)) || !empty(getbufvar(bnr, '&bt')) | return | endif
            system($'git -C {fnamemodify(bufname(bnr), ":p:h")} status -s')
            this.is_useful = (v:shell_error == 0)
            this.bufnr = bnr
        elseif this.is_useful && changedtick == this.changedtick
            var bname = bufname(bnr)
            var res = system($'git -C {fnamemodify(bname, ":p:h")} log -n 1 -- {fnamemodify(bname, ":p")}')
            var hashcode = (v:shell_error ? '' : res->slice(7, 7 + HashCodeLen))
            if this.buffer_hashcode == hashcode | return | endif
            this.buffer_hashcode = hashcode
        endif
        this.changedtick = changedtick
        if this.is_useful
            var msglist = systemlist($'git -C {expand("%:p:h")} diff HEAD -- {expand("%:p")}')
            if v:shell_error | return | endif
            sign_unplace(GitSignGroup, {buffer: this.bufnr})
            Mark(this.bufnr, msglist)
        endif
    enddef

    def GitDiffMark()
        var cname = get(g:, 'colors_name', 'default')
        if colorscheme_buffer != cname
            ConfigSign()
            colorscheme_buffer = cname
            this.changedtick -= 1
        endif
        this.Render()
    enddef

endclass

export def ConfigSign()
    if !empty(sign_getdefined('LxdGitDiffAdd'))
        sign_undefine(['LxdGitDiffAdd', 'LxdGitDiffDeleteBottom', 'LxdGitDiffDeleteTop', 'LxdGitDiffChanged', 'LxdGitDiffChangedAndDelete'])
    endif
    hi LxdGitDiffAdd term=bold ctermfg=Green  guifg=Green
    hi LxdGitDiffDelete term=bold ctermfg=Red  guifg=Red
    hi LxdGitDiffChanged term=bold ctermfg=Yellow guifg=Orange
    hi LxdGitDiffChangedAndDelete term=bold ctermfg=Yellow guifg=Yellow
    # in insert mode , '┃' = <c-k>VV ; '⊥' = <c-k>-T ; '‾' = <c-k>'- '┻' = <c-k>UH '_' = <c-k>__
    sign_define('LxdGitDiffAdd', {text: "┃", texthl: 'LxdGitDiffAdd'})
    sign_define('LxdGitDiffDeleteTop', {text: " ‾", texthl: 'LxdGitDiffDelete'})
    sign_define('LxdGitDiffDeleteBottom', {text: " _", texthl: 'LxdGitDiffDelete'})
    sign_define('LxdGitDiffChanged', {text: "┃", texthl: 'LxdGitDiffChanged'})
    sign_define('LxdGitDiffChangedAndDelete', {text: '┻', texthl: 'LxdGitDiffChangedAndDelete'})
enddef

const GitSignGroup	            = 'LxdGitDiff'
const AddSignId					= 1
const DeleteSignId				= 2
const ChangedSignId				= 3
const ChangedAndDeleteSignId	= 4
const SignZindex				= 11
def MarkAdd(bufnr: number, line_number: number)
    sign_place(AddSignId, GitSignGroup, 'LxdGitDiffAdd', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkDeleteTop(bufnr: number, line_number: number)
    sign_place(DeleteSignId, GitSignGroup, 'LxdGitDiffDeleteTop', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkDeleteBottom(bufnr: number, line_number: number)
    sign_place(DeleteSignId, GitSignGroup, 'LxdGitDiffDeleteBottom', bufnr, {lnum: line_number, priority: SignZindex})
enddef

def MarkChanged(bufnr: number, line_number: number)
    sign_place(ChangedSignId, GitSignGroup, 'LxdGitDiffChanged', bufnr, {lnum: line_number, priority: SignZindex + 1})
enddef

def MarkChangedAndDelete(bufnr: number, line_number: number)
    sign_place(ChangedAndDeleteSignId, GitSignGroup, 'LxdGitDiffChangedAndDelete', bufnr, {lnum: line_number, priority: SignZindex + 2})
enddef

def GetLineFlagChar(str: string): string
    return empty(str) ? ' ' : str[0]
enddef

const MATCH_SCRIPT = '^@@ -\([0-9]*\),\([0-9]*\) +\([0-9]*\),\([0-9]*\) @@'
def GetStartLineMatchList(str: string): list<number>
    var res_str = str->matchlist(MATCH_SCRIPT)
    return empty(res_str) ? null_list : mapnew(res_str, "str2nr(v:val)")->slice(1, 5)
enddef

import './std/global.vim' as global
#var code = global.DebugCode
var code = 10
var Log = global.GetFileLog(code, 'test gitdiff Mark()')
const ADD_FLAG		= 0b01
const DELETE_FLAG	= 0b10
const CHANGE_FLAG	= 0b11
export def Mark(bufnr: number, msglist: list<string>)
    const LEN = len(msglist)
    var li = 1
    while li < LEN
        var sml = GetStartLineMatchList(msglist[li])
        ++li
        if sml == null_list | continue | endif
        const MINUS_COUNT	= sml[1]
        const PLUS_COUNT	= sml[3]
        const FLAG_LIST_LEN = PLUS_COUNT + MINUS_COUNT
        var mn = 0
        var pn = 0
        while pn < PLUS_COUNT || mn < MINUS_COUNT
            var flaglist = repeat([0], FLAG_LIST_LEN)
            #while (mn < MINUS_COUNT || pn < PLUS_COUNT) && GetLineFlagChar(msglist[li]) == ' '
            while mn < MINUS_COUNT && pn < PLUS_COUNT && GetLineFlagChar(msglist[li]) == ' '
                ++li
                ++pn
                ++mn
            endwhile

            const BASE_LINE_NUMBER = sml[2] + pn
            var cnt_add     = 0
            var cnt_delete  = 0
            while mn < MINUS_COUNT && GetLineFlagChar(msglist[li]) == '-'
                Log($'msglist[li]:{li}: ', msglist[li])
                flaglist[cnt_delete] = or(flaglist[cnt_delete], DELETE_FLAG)
                ++cnt_delete
                ++mn
                ++li
            endwhile

            while pn < PLUS_COUNT && GetLineFlagChar(msglist[li]) == '+'
                Log($'msglist[li]:{li}: ', msglist[li])
                flaglist[cnt_add] = or(flaglist[cnt_add], ADD_FLAG)
                ++cnt_add
                ++pn
                ++li
            endwhile

            if cnt_add == 0 && cnt_delete == 0 | break | endif

            var line = BASE_LINE_NUMBER - 1
            if cnt_add == 0
                if line == 0    | MarkDeleteTop(bufnr, 1)
                else            | MarkDeleteBottom(bufnr, line) | endif
                continue
            endif

            for i in range(cnt_add)
                if		flaglist[i] == ADD_FLAG		| MarkAdd(bufnr, BASE_LINE_NUMBER + i)
                elseif	flaglist[i] == CHANGE_FLAG	| MarkChanged(bufnr, BASE_LINE_NUMBER + i)
                endif
            endfor

            if cnt_delete > cnt_add | MarkChangedAndDelete(bufnr, BASE_LINE_NUMBER + cnt_add - 1) | endif
        endwhile

    endwhile
enddef

class AsyncGitDiffMsg extends GitDiffMsg
    def Render()
        var bnr = bufnr()
        var changedtick = getbufvar(bnr, 'changedtick')
        if bnr != this.bufnr
            if empty(bufname(bnr)) || !empty(getbufvar(bnr, '&bt')) | return | endif
            this.is_useful = false
            async_shell_session.Execute(
                $'git -C {fnamemodify(bufname(bnr), ":p:h")} status',
                (msg) => {
                    this.is_useful = true
                    AsyncMark(bnr)
                }
            )
            this.bufnr = bnr
        elseif this.is_useful
            if changedtick != this.changedtick | AsyncMark(bnr)
            else
                var bname = bufname(bnr)
                async_shell_session.Execute(
                    $'git -C {fnamemodify(bname, ":p:h")} log -n 1 -- {fnamemodify(bname, ":p")}',
                    (msg) => {
                        if msg->slice(0, 6) != 'commit' | return | endif
                        var hashcode: string = msg->slice(7, 7 + HashCodeLen)
                        if hashcode == this.buffer_hashcode | return | endif
                        AsyncMark(bnr)
                        this.buffer_hashcode = hashcode
                    }
                )
            endif
        endif
        this.changedtick = changedtick
    enddef
endclass

def AsyncMark(bufnr: number)
    sign_unplace(GitSignGroup, {buffer: bufnr})
    async_shell_session.Execute($'git -C {expand("%:p:h")} diff HEAD -- {expand("%:p")}', (msg) => Mark(bufnr, msg->split("\n")))
enddef

var Run = null_function
export def Setup()
    var flag = get(g:, 'lxd_async_gitidff_enable', true)
    if !flag && !get(g:, "lxd_gitidff_enable", true) | return | endif
    var gitdiff = flag ? AsyncGitDiffMsg.new() : GitDiffMsg.new()
    Run = gitdiff.GitDiffMark
    command! TriggerGitDiffMark Run()
enddef
