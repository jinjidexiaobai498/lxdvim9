vim9script
import './std/global.vim' as G
import './std/view.vim' as view
import './std/listenner.vim' as listenner

const FILE_TAB			= '-f-    >'
const DIRECTORY_TAB		= '-d->'
const FTAB_LEN          = len(FILE_TAB)
const DTAB_LEN          = len(DIRECTORY_TAB)
const GENERATE_BUFNAME	= '___WorkSpace___'

var KeymapEdit = null_function
export class WorkSpace
    static var ID = 1
    static def DefaultWorkSpaceWinlayoutOpen()
        exe ':20 vsplit'
    enddef

    static def ConfigLocalBuffer()
        view.ConfigLocalHiddenToggleBuffer()
        setlocal buftype=nofile
    enddef

    var bufnr = -1
    var WindowLayoutOpen: func
    var WindowLayoutHidden: func
    var width = 20
    var is_init = false
    var project_dict: dict<any> = {}
    var line_file_map: dict<any> = {}
    var line_project_map: dict<any> = {}
    public var buflist: list<number> = []
    public var is_sync = true

    def Render(bufnr: number)
        if this.is_sync || !this.is_init | return | endif
        win_execute(bufwinid(bufnr), "normal dG")
        this.project_dict = {}
        this.line_file_map = {}
        this.line_project_map = {}

        for bnr in this.buflist
            if bnr == bufnr | continue | endif
            var bufname = fnamemodify(bufname(bnr), ':p')
            var pname = G.GetProjectRoot(bufname)
            var iname = bufname->slice(len(pname))
            if !this.project_dict->has_key(pname) | this.project_dict[pname] = [iname]
            else | this.project_dict[pname]->add(iname) | endif
        endfor

        setbufline(bufnr, 1, 'WorkSpace Brower')

        this.width = 10
        var i = 1
        for [pname, flist] in this.project_dict->items()
            ++i
            setbufline(bufnr, i, '')
            ++i
            setbufline(bufnr, i, DIRECTORY_TAB .. pname)
            this.line_file_map[i]       = pname
            this.line_project_map[i]    = ''
            this.width                  = max([len(pname) + DTAB_LEN, this.width])
            sort(flist)
            for fname in flist
                ++i
                setbufline(bufnr, i, FILE_TAB .. fname)
                this.line_file_map[i]       = fname
                this.line_project_map[i]    = pname
                this.width                  = max([len(fname) + FTAB_LEN, this.width])
            endfor
        endfor
        this.width += 2
        this.is_sync = true
    enddef

    def new(WinOpen: func = null_function, WinHidden: func = null_function)
        this.WindowLayoutOpen = G.OR(WinOpen, DefaultWorkSpaceWinlayoutOpen)
        this.WindowLayoutHidden = G.OR(WinHidden, view.SafeCloseWindow)
    enddef

    def Init(): bool
        if this.is_init | return true | endif
        this.is_init = true
        ID += 1
        this.bufnr = bufadd($'{GENERATE_BUFNAME}_{ID}')
        this.Open()
        this.KeymapConfig()
        ConfigLocalBuffer()
        return false
    enddef

    def Open()
        this.WindowLayoutOpen()
        exe $'noa buffer {this.bufnr}'
        this.Render(this.bufnr)
        exe $"noa vert resize {this.width}"
    enddef

    def Close()
        this.WindowLayoutHidden()
    enddef

    def Toggle()
        if !this.Init() | return | endif
        view.ToggleBufferView(this.bufnr, this.Open, this.Close)
    enddef

    def KeymapConfig()
        KeymapEdit = () => {
            var lnr = line('.')
            if !this.line_project_map->has_key(lnr) || empty(this.line_project_map[lnr]) | return | endif
            this.Toggle()
            exe $"edit {this.line_project_map[lnr]}{this.line_file_map[lnr]}"
        }
        nmap <buffer> q :close<CR>
        nmap <buffer> e <ScriptCmd>KeymapEdit()<CR>
        nmap <buffer> <Enter> <ScriptCmd>KeymapEdit()<CR>
    enddef

endclass

var WorkSpaceRun = null_function
export def WorkSpaceSetup()
    var wk = WorkSpace.new()
    listenner.buffer_read_callback_list->add(
        (bufnr, bufmap) => {
            if !bufmap->has_key(bufnr)
                wk.buflist->add(bufnr)
                wk.is_sync = false
            endif
        }
    )
    listenner.buffer_delete_callback_list->add(
        (bufnr, bufmap) => {
            if bufmap->has_key(bufnr)
                wk.buflist->remove(wk.buflist->index(bufnr))
                wk.is_sync = false
            endif
        }
    )

    WorkSpaceRun = () => wk.Toggle()
    nmap <Plug>ToggleWorkSpace <ScriptCmd>WorkSpaceRun()<CR>
enddef

var NetrwToggleOpen = null_function
var NetrwToggleRun = null_function
def NetrwToggleSetup()
    NetrwToggleOpen = () => {
        exe ":20 Sexplore!"
        nnoremap <buffer> q <Cmd>q<CR>
    }
    var netrw = view.ProtoView.new(NetrwToggleOpen)
    NetrwToggleRun = () => netrw.Toggle()
    nmap <Plug>NetrwToggle <ScriptCmd>NetrwToggleRun()<CR>
enddef

export def Setup()
    WorkSpaceSetup()
    NetrwToggleSetup()
enddef
