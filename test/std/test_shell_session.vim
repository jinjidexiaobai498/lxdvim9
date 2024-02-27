vim9script
import '../../builtin_plugin/std/shell_session.vim' as shell_session
import "../../builtin_plugin/std/global.vim" as global
var Log = global.GetFileLog(global.DebugCode, 'Test ShellSession')

def TestShellSessionRg()
    var time = reltime()
    shell_session.Execute('rg ls ~/Projects/lxdvimrc', (msg) => {
        echom 'rg test' msg
        Log('rg shell_session time test', time->reltime()->reltimestr())
    })
enddef
TestShellSessionRg()
