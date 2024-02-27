vim9script
export const UseWindows		= has('win32') || has('win64')
export const Backslash		= UseWindows ? '\' : '/'
export const HOME			= expand('~')
export const DATA_DIR		= expand('~/.vim')
export const CONFIG_DIR		= expand('~/.config/vim')
export const SELF_PATH		= expand('<sfile>:p:h')
export const TAB			= '    '
export const BASHES_MAP     = {'sh': true, 'bash': true, 'zsh': true}
export const SHELL          = () => {
    for s in ['/bin/zsh', '/bin/bash', '/bin/sh', 'pwsh', 'powershell', 'cmd']
        if executable(s) | return s | endif
    endfor
    return &shell
}()

# get  project root
const HOME_LEN = UseWindows ? 3 : 1
export def GetParentPath(path: string): string
    var last_index = path->strridx(Backslash)
    if last_index < HOME_LEN | return null_string | endif
    return path[ : last_index - 1]
enddef

export def IsGitProject(path: any = ''): bool
    var bname = bufname(path)
    var p = fnamemodify(empty(bname) ? path : bname, ':p:h')
    while p != null_string
        if isdirectory($'{p}{Backslash}.git') | return true | endif
        p = GetParentPath(p)
    endwhile
    return false
enddef

const PROJECT_LABLE = {'.git': "git", "Cargo.toml": "Cargo", 'CMakeList.txt': "CMake", "Makefile": "make", "package.json": "node"}
export def GetProjectDeal(path: string, DealFunc: func)
    var parent_filename = fnamemodify(path, ':p:h')
    var p = parent_filename->copy()
    while p != null_string
        var subs = readdir(p)
        for i in readdir(p)
            if PROJECT_LABLE->has_key(i)
                DealFunc(PROJECT_LABLE[i], p)
                return
            endif
        endfor
        for i in PROJECT_LABLE->keys()
            if subs->index(i) != -1
                DealFunc(PROJECT_LABLE[i], p)
                return
            endif
        endfor
        p = GetParentPath(p)
    endwhile
    DealFunc('SingleFile', parent_filename)
enddef

var local_buffer_map: dict<string> = {}
export def GetProjectRoot(path: any = ''): string
    var lpath = fnamemodify(empty(bufname(path)) ? path : bufname(path), ":p:h")
    if local_buffer_map->has_key(lpath) | return local_buffer_map->get(lpath) | endif
    var res = ""
    GetProjectDeal(lpath, (label, root) => {
        res = root
    })
    local_buffer_map[lpath] = res
    return res
enddef

var project_name_buffer_map = {}
export def GetProjectName(path: any = ''): string
    var lpath = fnamemodify(empty(bufname(path)) ? path : bufname(path), ":p")
    var ppath = fnamemodify(lpath, ":h")
    if project_name_buffer_map->has_key(ppath) | return project_name_buffer_map->get(ppath) | endif
    var res = ""
    GetProjectDeal(lpath, (label, root) => {
        res = (label == 'SingleFile' ? lpath : root)
    })
    project_name_buffer_map[ppath] = res
    return res
enddef

const FlagList = ['RECORD', 'DEBUG', 'INFO', 'ERROR']
export const RecordCode = 0
export const DebugCode  = 1
export const InfoCode   = 2
export const ErrorCode  = 3
export const LogfileName = $'{GetProjectRoot(SELF_PATH)}{Backslash}test{Backslash}test.log'
def GenerateFileLog(...msgs: list<any>)
    echom join(msgs)
    writefile([join(msgs)], LogfileName, 'a')
enddef

def FlagLog(...msgs: list<any>)
    echom join(msgs)
enddef

def EmptyLog(...msgs: list<any>)
enddef

export def GetFileLog(flag: number, ...pre_msgs: list<any>): func
    if flag < 0 || flag > 3 | return funcref(EmptyLog) | endif
    return funcref(GenerateFileLog, [$'[{FlagList[flag]}]', pre_msgs])
enddef

export def GetLog(flag: bool, ...pre_msgs: list<any>): func
    if !flag | return funcref(EmptyLog) | endif
    return funcref(FlagLog, [flag, pre_msgs])
enddef

def AssertTrueDefine(error: string, expr: bool, ...msgs: list<any>)
    if expr | return | endif
    echom join(msgs)
    throw error
enddef

export def GetAssertTrue(error: string): func
    return funcref(AssertTrueDefine, [error])
enddef

export def OR(...obs: list<any>): any
    for i in obs | if !(!(i)) | return i | endif | endfor
    return null
enddef

# print any object in vim
def IndentString(str: string, tabnum: number = 1): string
    var res = ''
    if tabnum > 0 | res ..= TAB->repeat(tabnum) | endif
    return res .. str
enddef

export def Align(obj: any, tabn: number = 8): string
    var res = (type(obj) == 1 ? obj : string(obj))
    var l = tabn - len(res)
    return res .. (repeat([' '], l >= 0 ? l : 0)->join(''))
enddef

export def Inspect(obj: any, tabnum: number = 1, last_type = -1): string
    var res = ''
    var t = type(obj)
    if t == type({})
        if len(obj) == 0 | return Inspect('{}', tabnum + 1, t) | endif
        res ..= "\n" .. IndentString("{\n", tabnum - 1)
        for i in keys(obj) | res ..= IndentString(i->string() .. " : ", tabnum) .. Inspect(obj[i], tabnum + 2, t)  .. ",\n" | endfor
        res ..= IndentString('}', tabnum - 1)
    elseif t == type([])
        if len(obj) == 0 | return Inspect('[]', tabnum + 1, t) | endif
        res ..= "\n" .. IndentString("[\n", tabnum - 1)
        for i in obj | res ..= Inspect(i, tabnum + 1, t)  .. ",\n" | endfor
        res ..= IndentString(']', tabnum - 1)
    else
        if last_type == type({}) | return (obj->string()) | endif
        return IndentString((obj->string()), tabnum - 1)
    endif
    return res
enddef

export def Print(obj: any, tabnum: number = 1)
    echo Inspect(obj, tabnum)
enddef
