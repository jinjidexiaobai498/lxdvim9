vim9script
import "../../builtin_plugin/std/project.vim" as project
import "../../builtin_plugin/std/global.vim" as global
var Log = global.GetFileLog(global.DebugCode, 'Test project')

def TestGetProjectFilesList()
    var time = reltime()
    project.GetProjectFilesList(expand('%:h'), (msglist) => {
        echom 'GetProjectFilesList' msglist
        Log('GetProjectFilesList time test', time->reltime()->reltimestr())
    })
enddef

def TestIsGitProject()
    var time = reltime()
    project.IsGitProject(expand('%:h'), (msg) => {
        echom 'IsGitProject' msg
        Log('IsGitProject time test', time->reltime()->reltimestr())
    })
enddef

def TestGetProjectRoot()
    var time = reltime()
    project.GetProjectRoot(expand('%:h'), (msg) => {
        echom 'GetProjectRoot' msg
        Log('GetProjectRoot time test', time->reltime()->reltimestr())
    })
enddef

def TestGitProjectGrep()
    var time = reltime()
    project.GitProjectGrep('-e this --and -e Search', expand('%:h'), (msg) => {
        echom 'GitProjectGrep' msg
        Log('GitProjectGrep time test', time->reltime()->reltimestr())
    })
enddef

#ch_logfile('test_project_log', 'w')
def Test()
    TestIsGitProject()
    #TestGitProjectGrep()
    #TestGetProjectRoot()
    #TestGetProjectFilesList()
enddef

nmap <leader>z <ScriptCmd>Test()<CR>
