vim9script
const HELP_TEXT =<< trim END
Press Keys        : Effection
<F1>              : Show help info
s <Space>         : Load but not exit
<Enter>           : Load and exit
q <Ctrl-c> <ESC>  : Exit and not load
j k               : Move the cursor
r x d             : Mark delete selected
END

const DELETE_KEY_MAP    = {'r': true, 'x': true, 'd': true}
const SELECT_KEY_MAP    = {'s': true, "\<Space>": true}
const EXIT_AND_SELECT   = {'w': true}
const EXIT_NOT_SELECT   = {'q': true, "\<c-c>": true, "\<ESC>": true}
export class PopupMenu
    public var option = {
        callback: this.Callback,
        filter: this.Filter,
        cursorline: true,
        minwidth: 30,
        maxheight: 30,
        hidden: false,
        tabpage: -1,
        wrap: true,
        drag: true,
        close: 'button',
        padding: [1, 1, 1, 1],
        border: [1, 1, 1, 1],
        scroller: true,
    }
    var removed_selected_list: list<number> = []
    var popup_menu_disp_list: list<string> = []
    var content: list<string> = null_list
    var winid = -1
    var title: string
    var GetContent: func
    var SaveContent: func
    var DealSelected: func
    var RenderLines: func

    def new(this.title, this.GetContent, this.SaveContent, this.DealSelected, RenderFunc = null_function)
        this.RenderLines = (!RenderFunc ? ((line) => line->copy()) : RenderFunc)
        this.option.title = this.title
        this.content = this.GetContent()
        this.popup_menu_disp_list = this.RenderLines(this.content)
    enddef

    def Filter(winid: number, key: string): bool
        if SELECT_KEY_MAP->has_key(key)
            win_execute(winid, '@l = line(".")')
            var idx = str2nr(@l) - 1
            if this.removed_selected_list->index(idx) != -1 | return true | endif
            this.DealSelected(this.content[idx])
        elseif DELETE_KEY_MAP->has_key(key)
            win_execute(winid, '@l = line(".")')
            var lnum = str2nr(@l)
            var mlist_index = lnum - 1
            var rlist_index = this.removed_selected_list->index(mlist_index)

            @t = this.popup_menu_disp_list[mlist_index]
            if rlist_index != -1
                this.removed_selected_list->remove(rlist_index)
            else
                this.removed_selected_list->add(mlist_index)
                @t = $'[x]{@t}'
            endif
            win_execute(winid, 'setline(str2nr(@l), @t)')
        elseif EXIT_AND_SELECT->has_key(key)
            win_execute(winid, '@l = line(".")')
            popup_close(winid, str2nr(@l))
        elseif EXIT_NOT_SELECT->has_key(key)
            popup_close(winid, -1)
        elseif key == "\<F1>"
            popup_menu(HELP_TEXT, {zindex: 201})
        else
            return popup_filter_menu(winid, key)
        endif
        return true
    enddef

    def Callback(winid: number, result: any)
        if result < 2 | return | endif
        var idx = result - 1
        if this.removed_selected_list->index(idx) == -1 | this.DealSelected(this.content[idx]) | endif
        if empty(this.removed_selected_list) | return | endif
        uniq(sort(this.removed_selected_list))
        for i in range(len(this.removed_selected_list)) | this.content->remove(this.removed_selected_list[i] - i) | endfor
        this.removed_selected_list = []
        this.SaveContent(this.content)
        this.popup_menu_disp_list = this.RenderLines(this.content)
    enddef

    def PopupBrowser()
        echo 'Press <F1> to show help_text'
        this.winid = popup_menu(this.popup_menu_disp_list, this.option)
        win_execute(this.winid, 'setlocal cursorline')
    enddef

endclass

def Test()
    var po = PopupMenu.new(
        'test',
        () => {
            return ['111', '222', '333']
        },
        (s) => 0,
        (s) => {
            echom 'selected' s
        }
    )
    po.PopupBrowser()
enddef
#Test()
