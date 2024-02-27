vim9script
import './shell_session.vim' as shell_session
import './global.vim' as G

export const IS_GIT = executable('git')
export def IsGitProject(path: string, DealFunc: func, ErrorDeal: func = null_function)
    shell_session.Execute( $'git -C {path} rev-parse --is-inside-work-tree', DealFunc, ErrorDeal)
enddef

export def GetProjectRoot(path: string, DealFunc: func, ErrorDeal: func = null_function)
    shell_session.Execute( $'git -C {path} rev-parse --show-toplevel', DealFunc, ErrorDeal)
enddef

export def GetProjectFilesList(path: string, DealFunc: func, ErrorDeal: func = null_function)
    shell_session.Execute( $'git -C {path} ls-tree HEAD --full-tree --name-only -r', (msg) => DealFunc(split(msg, '\n')), ErrorDeal)
enddef

export def GitProjectGrep(content: string, path: string, DealFunc: func, ErrorDeal = null_function)
    echom 'command' $'git -C {path} grep -n --column --no-color {content}'
    shell_session.Execute($'git -C {path} grep -n --column --no-color {content}', (msg) => DealFunc(msg->split('\n')), ErrorDeal)
enddef
