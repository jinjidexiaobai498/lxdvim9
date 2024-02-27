vim9script

export class ProtoView
    var bufnr: number = -1
    var WindowLayoutOpen: func
    var WindowLayoutHidden: func
    def new(WinOpen: func = null_function, WinHidden: func = null_function)
        this.WindowLayoutOpen   = (!WinOpen ? DefaultWindowLayoutOpen : WinOpen)
        this.WindowLayoutHidden = (!WinHidden ? SafeCloseWindow : WinHidden)
    enddef

    def GetIsView(): bool
        return bufwinnr(this.bufnr) >= 0
    enddef

    def SetBufnr(bnr: number)
        this.bufnr = bnr
    enddef

    def Close()
        this.WindowLayoutHidden()
    enddef

    def Open()
        this.WindowLayoutOpen()
        this.bufnr = bufnr()
    enddef

    def Toggle()
        #AssertTrue(BufExists(this.bufnr),  'bufnr doesnot exist or unloaded, bufnr:', this.bufnr)
        ToggleBufferView(this.bufnr, this.Open, this.Close)
    enddef
endclass

export class View extends ProtoView

    def new(WinOpen: func = null_function, WinHidden: func = null_function)
        this.WindowLayoutOpen   = (!WinOpen ? DefaultWindowLayoutOpen : WinOpen)
        this.WindowLayoutHidden = (!WinHidden ? SafeCloseWindow : WinHidden)
    enddef

    def Open()
        this.WindowLayoutOpen()
        exe 'b ' .. this.bufnr
    enddef
endclass

def DefaultWindowLayoutOpen()
    :20 vsplit
enddef

export def SafeCloseWindow()
    try
        close
    catch /^Vim\%((\a\+)\)\=:E444:/
        vsplit | edit ~/.vimrc | :2close
    endtry
enddef

export def ConfigLocalHiddenToggleBuffer()
    setlocal winfixheight
    setlocal nonumber norelativenumber signcolumn=no
    setlocal bufhidden=hide
    setlocal nobuflisted
enddef

export def BufExists(bufnr: number): bool
    return (bufexists(bufnr) && !empty(bufname(bufnr)))
enddef

export def ClearBufferWindow(bufnr: number)
    if !BufExists(bufnr) | return | endif
    if bufwinnr(bufnr) >= 0 | SafeCloseWindow() | endif
    exe $'bdelete {bufnr}'
enddef

export def ToggleBufferView(bufnr: number, WinOpen: func, WinHidden: func)
    var wnr = bufwinnr(bufnr)
    if wnr < 0 | WinOpen()
    else
        var cwinid = win_getid()
        var winid = win_getid(wnr)
        if winid != cwinid | win_gotoid(winid) | endif
        WinHidden()
        if cwinid != win_getid() | win_gotoid(cwinid) | endif
    endif
enddef
