vim9script
import '../../builtin_plugin/std/global.vim' as global
var Log = global.GetFileLog(global.DebugCode, 'Test GetFileLog')

def TestGetProjectRoot()
    var time = reltime()
    #Log('GetProjectRoot', global.GetProjectRoot(''))
    echom global.GetProjectRoot('~/Projects/lxdvimrc/plugin')
    Log('GetProjectRoot time test', time->reltime()->reltimestr())
enddef

const UseWindows		= has('win32') || has('win64')
const Backslash		= UseWindows ? '\' : '/'
# get  project root
const HOME_LEN = UseWindows ? 3 : 1
def GetParentPath(path: string): string
    var last_index = path->strridx(Backslash)
    if last_index < HOME_LEN | return null_string | endif
    return path[ : last_index - 1]
enddef

const PROJECT_LABLE = {'.git': "git", "Cargo.toml": "Cargo", 'CMakeList.txt': "CMake", "Makefile": "make", "package.json": "node"}
def GetProjectRoot(path: string): string
    var parent_filename = fnamemodify(path, ':p:h')
    var p = parent_filename->copy()
    while p != null_string
        var subs = readdir(p)
        for i in PROJECT_LABLE->keys()
            if subs->index(i) != -1 | return p | endif
        endfor
        p = GetParentPath(p)
    endwhile
    return parent_filename
enddef

def GetProjectRoot4(path: string): string
    var parent_filename = fnamemodify(path, ':p:h')
    var p = parent_filename->copy()
    while p != null_string
        for i in readdir(p) | if PROJECT_LABLE->has_key(i) | return p | endif | endfor
        p = GetParentPath(p)
    endwhile
    return parent_filename
enddef

def GetProjectRoot2(path: string): string
    var parent_filename = fnamemodify(path, ':p:h')
    var p = parent_filename->copy()
    while p != null_string
        if isdirectory($'{p}{Backslash}.git') | return p | endif
        for i in PROJECT_LABLE->keys()
            if filereadable($'{p}{Backslash}{i}') | return p | endif
        endfor
        #if isdirectory($'p{Backslash}.git') | return p | endif
        p = GetParentPath(p)
    endwhile
    return parent_filename
enddef

def TestReaddirAndGlobpath()
    var path = expand('~/Projects/lxdvimrc')
    var time = reltime()
    echom 'globpath' isdirectory($'{path}{Backslash}.git')
    Log('globpath time test', time->reltime()->reltimestr())
    time = reltime()
    echom 'readdir' readdir(path)->index('.git')
    Log('readdir time test', time->reltime()->reltimestr())
enddef

def GetProjectRoot3(path: string): string
    var parent_filename = fnamemodify(path, ':p:h')
    var p = parent_filename->copy()
    while p != null_string
        #if isdirectory($'{p}{Backslash}.git') | return p | endif
        for i in PROJECT_LABLE->keys()
            if filereadable($'{p}{Backslash}{i}') || isdirectory($'{p}{Backslash}{i}') | return p | endif
        endfor
        #if isdirectory($'p{Backslash}.git') | return p | endif
        p = GetParentPath(p)
    endwhile
    return parent_filename
enddef

def Test()
    var path = bufname('')
    var time2 = reltime()
    echom 'GetProjectRoot readdir' GetProjectRoot(path)
    Log('GetProjectRoot readdir, time test', time2->reltime()->reltimestr())
enddef

def Test2()
    var path = bufname('')
    var time2 = reltime()
    echom 'GetProjectRoot2 isdirectory' GetProjectRoot2(path)
    Log('GetProjectRoot2 isdirectory, time test', time2->reltime()->reltimestr())
enddef

def Test3()
    var path = bufname('')
    var time = reltime()
    echom 'globpath' GetProjectRoot3(path)
    Log('GetProjectRoot3 isdirectory || filereadable, time test', time->reltime()->reltimestr())
enddef

def Test4()
    var time4 = reltime()
    echom 'GetProjectRoot4 readdir' GetProjectRoot4(bufname(''))
    Log('GetProjectRoot4 readdir, time test', time4->reltime()->reltimestr())
enddef

Test4()
#TestGetProjectRoot()
