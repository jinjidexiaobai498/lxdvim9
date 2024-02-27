vim9script
import "./global.vim" as G
import "./view.vim" as view

const SEARCH_RESULT_VIEW_LIMIT = 100
var last_input = '|'
def UpKeymap()
    exe $"normal A\<C-u>{last_input}"
enddef

def FzfNativeDefaultWinLayoutOpen()
    exe 'rightbelow :30 split'
enddef

var PlublicFunc = null_function
export class FzfNativeSearch extends view.ProtoView
    static var ID = 0
    static def GetName(): string
        ID += 1
        return $'__FzfNativeSearch__{ID}'
    enddef

    static def ConfigBuffer()
        set buftype=prompt
        view.ConfigLocalHiddenToggleBuffer()
        setlocal number relativenumber cursorline
        imap <buffer> <C-p> <ScriptCmd>UpKeymap()<CR>
        nmap <buffer> q :close<CR>
        nmap <buffer> <C-l> a<C-u>*<CR>
        imap <buffer> <C-l> <C-u>*<CR>
    enddef

    var is_init         = false
    var is_update       = false
    var is_async        = false
    var content         = {}
    var Context         = null_function
    var DealFunction    = null_function
    var GetPromptString = null_function
    var SearchFunc      = null_function
    def new(this.Context, this.SearchFunc, this.DealFunction, this.GetPromptString, WinOpen = null_function)
        this.WindowLayoutOpen   = (!WinOpen ? FzfNativeDefaultWinLayoutOpen : WinOpen)
        this.WindowLayoutHidden = view.SafeCloseWindow
    enddef

    def ClearBuffer()
        exe $'bdelete! {this.bufnr}'
        this.is_init = false
        this.is_update = false
    enddef

    def SearchAndAppend(input: string)
        last_input = input->copy()
        this.AsyncDeal(this.SearchFunc(this.content, input, this.AsyncDeal, this.MarkAsync))
    enddef

    def AsyncDeal(msglist: list<string>)
        if this.is_async        | this.is_async = false
        elseif !empty(msglist)  | append(line('$') - 1, msglist->reverse())
        endif
    enddef

    def MarkAsync()
        this.is_async = true
    enddef

    def Init()
        if this.is_init | return | endif
        this.content = this.Context(this.content, this.MarkUpdate)
        this.bufnr = bufadd(GetName())
        prompt_setcallback(this.bufnr, this.SearchAndAppend)
        prompt_setinterrupt(this.bufnr, this.ClearBuffer)
        prompt_setprompt(this.bufnr, this.GetPromptString(this.content))
    enddef

    def MarkUpdate()
        this.is_update = false
    enddef

    def Update()
        if !this.is_init | return | endif
        var tc = this.Context(this.content, this.MarkUpdate)
        if this.is_update | return | endif
        this.content = tc
        prompt_setprompt(this.bufnr, this.GetPromptString(this.content))
    enddef

    def InitConfigBuffer()
        if this.is_init | return | endif
        ConfigBuffer()
        startinsert
        this.is_init = true
    enddef

    def UpdateConfigBuffer()
        if this.is_update | return | endif
        this.DealFunction(this.content)
        this.is_update = true
    enddef

    def Open()
        this.Init()
        this.Update()
        this.WindowLayoutOpen()
        exe $'buffer {this.bufnr}'
        this.InitConfigBuffer()
        this.UpdateConfigBuffer()
    enddef

endclass

export class FzfNative extends FzfNativeSearch
    def new(this.Context, this.DealFunction, this.GetPromptString, WinOpen = null_function)
        this.WindowLayoutOpen   = (!WinOpen ? FzfNativeDefaultWinLayoutOpen : WinOpen)
        this.WindowLayoutHidden = view.SafeCloseWindow
    enddef

    def SearchAndAppend(input: string)
        last_input = input->copy()
        var msglist = this.content['msglist']
        if empty(msglist) | return | endif
        append(line('$') - 1, reverse(input == '*' ? copy(msglist) : matchfuzzy(msglist, input, {limit: SEARCH_RESULT_VIEW_LIMIT})))
    enddef
endclass
