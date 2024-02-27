vim9script
import './std/global.vim' as G
import './std/view.vim' as view

export class Terminal extends view.ProtoView
    static def DefaultTerminalWindowLayoutOpen()
        exe 'hori rightbelow :17 split'
    enddef
    var options = {norestore: 1, term_finish: 'open', term_kill: 'kill', exit_cb: (_job, status) => view.ClearBufferWindow(this.bufnr), hidden: 1}
    var shell: string
    var _job: job = null_job
    var open_bufnr = -1
    var is_cwd = false
    var is_init = false
    var is_config = false
    def new(WinOpen: func = null_function, WinHidden: func = null_function, shell = null_string, is_cwd = false)
        this.is_cwd = is_cwd
        this.shell = executable(shell) ? shell : G.SHELL
        this.WindowLayoutOpen   = (!WinOpen ?  DefaultTerminalWindowLayoutOpen : WinOpen)
        this.WindowLayoutHidden = (!WinHidden ? view.SafeCloseWindow : WinHidden)
    enddef

    def Init(): bool
        if job_status(this._job) != 'run'   | view.ClearBufferWindow(this.bufnr)
        elseif this.is_init                 | return true | endif
        if this.is_cwd
            this.open_bufnr = bufnr()
            this.options.cwd = G.GetProjectRoot('')
        endif
        this.bufnr = term_start(this.shell, this.options)
        this._job = term_getjob(this.bufnr)
        this.WindowLayoutOpen()
        exe $'b {this.bufnr}'
        view.ConfigLocalHiddenToggleBuffer()
        this.is_init = true
        return false
    enddef

    def Open()
        if !this.Init() | return | endif
        if this.is_cwd && bufnr() != this.open_bufnr
            this.open_bufnr = bufnr()
            var root = G.GetProjectRoot('')
            if root != this.options.cwd
                term_sendkeys(this.bufnr, $"cd {root}\<CR>")
                this.options.cwd = root
            endif
        endif
        this.WindowLayoutOpen()
        exe $'b {this.bufnr}'
        if mode() != 't' | exe 'normal i' | endif
    enddef
endclass

const TERM_LIST = ['wezterm', 'alacritty', 'xterm', 'uxterm', 'gnome-terminal', 'kgx']
var term_exe = ''
def ExternTerminalRun()
    if !empty(term_exe) | return | endif
    for te in TERM_LIST
        if executable(te)
            term_exe = te
            break
        endif
    endfor
    if !empty(term_exe) | system(term_exe)
    else  | echom 'no usable terminal exe' | endif
enddef

var VertTerminalToggle      = null_function
var HortTerminalToggle      = null_function
var HortTerminalCwdToggle   = null_function
export def Setup()
    var VertShow = () => {
        exe 'vert bo :60 split'
    }

    var HortShow = () => {
        exe 'hori rightbelow :14 split'
    }

    HortTerminalToggle      =  Terminal.new(HortShow).Toggle
    VertTerminalToggle      =  Terminal.new(VertShow).Toggle
    HortTerminalCwdToggle   =  Terminal.new(HortShow, null_function, null_string, true).Toggle

    nnoremap <Plug>HortTerminalToggle <ScriptCmd>HortTerminalToggle()<cr>
    tnoremap <Plug>HortTerminalToggle <c-\><c-n><ScriptCmd>HortTerminalToggle()<cr>
    nnoremap <Plug>VertTerminalToggle <ScriptCmd>VertTerminalToggle()<cr>
    tnoremap <Plug>VertTerminalToggle <c-\><c-n><ScriptCmd>VertTerminalToggle()<cr>
    nnoremap <Plug>HortTerminalCwdToggle <ScriptCmd>HortTerminalCwdToggle()<cr>
    tnoremap <Plug>HortTerminalCwdToggle <c-\><c-n><ScriptCmd>HortTerminalCwdToggle()<cr>
    nnoremap <Plug>ExternTerminal <ScriptCmd>ExternTerminalRun()<CR>
enddef
