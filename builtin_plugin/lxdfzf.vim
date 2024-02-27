vim9script
import './std/global.vim' as G
import './std/listenner.vim' as listenner
import "./std/popup.vim" as popup
import "./std/fzf_native.vim" as fzn
import "./std/project.vim" as project

const FILE_HISTORY_PATH      = expand('~/.vim/lxd_file_history.txt')
const PROJECT_HISTORY_PATH   = expand('~/.vim/lxd_project_history.txt')
const PROJECT_CONTENT_PATH   = expand('~/.vim/lxd_project_content.txt')
const History_Limit_Lenght   = 100
const SplitChar              = '¦'

var one_time = false
def FileHistorySave(file_history_list: list<number>)
    if empty(file_history_list) | return | endif
    if one_time | return | endif
    one_time = true

    var pmap = {}
    var projectlist = []
    var filelist = []
    for bnr in file_history_list
        var filename = fnamemodify(bufname(bnr), ':p')
        filelist->add(filename)
        var pname = G.GetProjectName(filename)
        var iname = len(filename) == len(pname) ? filename : slice(filename, len(pname))
        if pmap->has_key(pname)
            projectlist->remove(projectlist->index(pname))
            pmap[pname]->add(iname)
        else
            pmap[pname] = [iname]
        endif
        projectlist->add(pname)
    endfor

    HistorySave(projectlist, PROJECT_HISTORY_PATH)
    HistorySave(filelist, FILE_HISTORY_PATH)

    var pcmap = ProjectContentGet()
    for [pname, pflist] in items(pmap) | pcmap[pname] = pflist | endfor
    ProjectContentSave(pcmap)
enddef

def ProjectContentSave(pmap: dict<any>)
    var res = []
    for [pname, pflist] in pmap->items()
        res->add($'{pname}{SplitChar}{len(pflist)}')
        res->extend(pflist)
    endfor
    writefile(res, PROJECT_CONTENT_PATH, 's')
enddef

def ProjectContentGet(): dict<any>
    var pmap = {}
    var pclist = filereadable(PROJECT_CONTENT_PATH) ? readfile(PROJECT_CONTENT_PATH) : []
    var pclen = len(pclist)
    var i = 0
    while i < pclen
        var [pname, ptlen] = pclist[i]->split(SplitChar)
        if !pmap->has_key(pname) | pmap[pname] = [] | endif
        var plen = str2nr(ptlen)
        ++i
        pmap[pname]->extend(slice(pclist, i, i + plen))
        i += plen
    endwhile
    return pmap
enddef

def Contact(newlist: list<string>, oldfiles: list<string>): list<string>
    var llen = len(newlist)
    var res = reverse(newlist)
    var lmap = {}
    for i in newlist | lmap[i] = true | endfor
    for file in oldfiles
        if lmap->has_key(file) | continue | endif
        res->add(file)
        llen += 1
        if llen >= History_Limit_Lenght | break | endif
    endfor
    return res
enddef

def HistorySave(newlist: list<string>, FILENAME: string)
    var plist = []
    var plen = len(newlist)
    if plen < History_Limit_Lenght  | plist = filereadable(FILENAME) ? Contact(newlist, readfile(FILENAME)) : []
    else                            | plist = newlist->slice(plen - History_Limit_Lenght) | endif
    writefile(plist, FILENAME, 's')
enddef

var ProjectSessionPopupRun = null_function
def ProjectHistoryPopupSetup()
    # ------------------------ProjectHistoryPopup------------------------------
    var pm = popup.PopupMenu.new(
        'ProjectHistoryPopup',
        () => filereadable(PROJECT_HISTORY_PATH) ? readfile(PROJECT_HISTORY_PATH) : [],
        (content) => writefile(content, PROJECT_HISTORY_PATH, 's'),
        (selected) => {
            var tmpb = bufnr()
            for item in ProjectContentGet()->get(selected, [])
                var fulname = (selected == item) ? item : $'{selected}{item}'
                if bufexists(fulname) | continue | endif
                var bnr = bufadd(fulname)
                bufload(fulname)
                exe $'b {bnr}'
                setlocal bl
            endfor
            exe $'b {tmpb}'
        }
    )
    ProjectSessionPopupRun = () => pm.PopupBrowser()
    nmap <Plug>ProjectHistoryPopup <ScriptCmd>ProjectSessionPopupRun()<CR>
enddef

const COLOR_LIST_FILE           = expand('~/.vim/colors_selected_file.vimd')
const COLOR_SEARCH_PATH_PREFIX  = $'colors{G.Backslash}*.vim'
var ColorsSeletedRun = null_function
def ColorsSelectedAndSave()
    # ------------------------ColorsSelect-------------------------------------
    augroup ColorsSelectedSave
        au!
        autocmd VimLeave * writefile([get(g:, 'colors_name', 'default')], COLOR_LIST_FILE, 's')
    augroup END

    var color = filereadable(COLOR_LIST_FILE) ? readfile(COLOR_LIST_FILE)[0] : "default"
    if color != get(g:, 'colors_name', 'default') | exe $'colorscheme {color}' | endif

    var colors = []
    for path in globpath(&rtp, COLOR_SEARCH_PATH_PREFIX, false, true)
        colors->add(path->slice(strridx(path, G.Backslash) + 1, strridx(path, '.')))
    endfor

    var po = popup.PopupMenu.new(
        'ColorSelectList',
        () => colors,
        (selected) => 0,
        (selected) => {
            if get(g:, 'colors_name', 'default') != selected | exe $'colorscheme {selected}' | endif
        }
    )

    ColorsSeletedRun = () => {
        po.PopupBrowser()
        win_execute(po.winid, $'normal {colors->index(get(g:, "colors_name", "default"))}j')
    }
    nmap <Plug>ColorsPopupBrowser <ScriptCmd>ColorsSeletedRun()<CR>
enddef

var FzfFuntionsRun = null_function
var FzfFunctionsDeal = null_function
def FzfFuntionsSetup()
    var fzf_functions = fzn.FzfNative.new(
        (map, MarkUpdate) => {
            var functions = ''
            redir => functions | silent exe 'function' | redir END
            return {msglist: (functions->split('\n'))}
        },
        (map) => {
            FzfFunctionsDeal = () => {
                var str = getline('.')
                var view = ''
                redir => view | exe 'verbose function ' .. str->slice(stridx(str, ' ') + 1, stridx(str, '(')) | redir END
                popup_dialog(view->split('\n'), {filter: 'popup_filter_menu', padding: [2, 4, 2, 4]})
            }
            nmap <buffer> <Enter> <ScriptCmd>FzfFunctionsDeal()<CR>
        },
        (map) => '>>Native Functions: '
    )

    FzfFuntionsRun  = () => fzf_functions.Toggle()
    nmap <Plug>FZFFunctions     <ScriptCmd>FzfFuntionsRun()<CR>
    #command! Files      FzfFilesRun()
enddef

var FzfFilesRun = null_function
var FzfFilesDeal = null_function
def FzfFilesSetup()
    var fzf_files = fzn.FzfNativeSearch.new(
        (map, MarkUpdate) => {
            var root = G.GetProjectRoot()
            if map->has_key('project_root') && root == map.project_root | return {} | endif
            MarkUpdate() 
            return {project_root: root}
        },
        (map, input, Async, Mark) => {
            var res = []
            if G.IsGitProject(map.project_root)
                Mark()
                project.GetProjectFilesList(map.project_root, (msglist) => Async(input == '*' ? msglist : matchfuzzy(msglist, input)))
                return []
            else
                var prefix_len = len(map.project_root) + 2
                for item in globpath(map.project_root, "/**", 0, 1) | if filereadable(item) | res->add(slice(item, prefix_len)) | endif | endfor
                return (input == '*') ? res : matchfuzzy(res, input)
            endif
        },
        (map) => {
            FzfFilesDeal = () => {
                var input = getline(".")
                FzfFilesRun()
                exe $'edit {map.project_root}{G.Backslash}{input}'
            }
            nmap <buffer> <Enter> <ScriptCmd>FzfFilesDeal()<CR>
        },
        (map) => {
            return $'>>>>>>>>>>>>>>>>>>>FindFiles:>>{map.project_root}%'
        }
    )
    FzfFilesRun     = () => fzf_files.Toggle()
    nmap <Plug>FzfNative_Files  <ScriptCmd>FzfFilesRun()<CR>
    #command! Maps       FzfMapsRun()
enddef

var FzfMapsDeal = null_function
var FzfMapsRun = null_function
def FzfMapsSetup()
    var fzf_maps = fzn.FzfNative.new(
        (map, MarkUpdate) => {
            var maps = ''
            redir => maps | silent exe 'map' | redir END
            return {msglist: (split(maps, "\n")->filter('v:val->slice(3, 9) != "<Plug>"'))}
        },
        (map) => {
            FzfMapsDeal = () => {
                var line = getline('.')
                if line[0] != 'n' | return | endif
                var cmd = line->slice(3, line->stridx(' ', 3))
                if cmd[0] == '<' | cmd = '\' .. cmd | endif
                exe $"normal {cmd}"
            }
            nmap <buffer> <Enter> <ScriptCmd>FzfMapsDeal()<CR>
        }, (map) => {
            return '>>Native Maps: '
        }
    )
    FzfMapsRun = () => fzf_maps.Toggle()
    nmap <Plug>FZFMaps <ScriptCmd>FzfMapsRun()<CR>
    command! Functions  FzfFuntionsRun()
enddef

def GetProjectGrep(path: string, content: string, fzf_flag = false): list<dict<any>>
    try
        exe $"vimgrep /{content}/gj{fzf_flag ? 'f' : ''} {path}/**"
    catch /^Vim\%((\a\+)\)\=:E480:/ # catch error E123
        echom $'FzfGrep: no found match in "{path}"'
        return []
    endtry
    return getqflist()
enddef

const FzfGrepSplitChar = '¦'
var FzfGrepRun = null_function
var FzfGrepDeal = null_function
def FzfGrepSetup()
    var fzf_grep = fzn.FzfNativeSearch.new(
        (map, MarkUpdate) => {
            var root = G.GetProjectRoot()
            if map->has_key('project_root') && root == map.project_root | return {} | endif
            MarkUpdate() 
            return {project_root: root}
        },
        (map, input, Async, Mark) => {
            var lroot = map.project_root
            var res = []
            const ALIGN_LEN = 5
            if G.IsGitProject(lroot) && !G.UseWindows
                const SC = ':'
                Mark()
                project.GitProjectGrep(input, lroot, (msglist) => {
                    for val in msglist
                        var firstIndex  = val->stridx(SC)
                        var secondIndex = val->stridx(SC, firstIndex + 1)
                        var rval = val
                        rval = rval->substitute(SC, FzfGrepSplitChar, '')
                        rval = rval->substitute(SC, FzfGrepSplitChar, '')
                        rval = rval->substitute(SC, FzfGrepSplitChar, '')
                        var linelist = rval->split(FzfGrepSplitChar)
                        echom 'linelist' linelist
                        res->add([linelist[0], G.Align(linelist[1], ALIGN_LEN), G.Align(linelist[2], 3), linelist[3]]->join(FzfGrepSplitChar))
                    endfor
                    Async(res)
                    res = []
                })
            else
                var founds = input[0] == '!' ? GetProjectGrep(lroot, input->slice(1), true) : GetProjectGrep(lroot, input)
                const P_LEN = len(lroot)
                for item in founds
                    var slnum = string(item.lnum)
                    res->add([fnamemodify(bufname(item.bufnr), ":p")->slice(P_LEN), G.Align(item.lnum, ALIGN_LEN), G.Align(item.col, 3), item.text]->join(FzfGrepSplitChar))
                endfor
            endif
            return res
        },
        (map) => {
            FzfGrepDeal = () => {
                var content = getline('.')->split(FzfGrepSplitChar)
                if len(content) != 4 | return | endif
                FzfGrepRun()
                exe $'edit {map.project_root}{G.Backslash}{content[0]}'
                exe $'normal {trim(content[1])}G0{trim(content[2])}lh'
            }
            nmap <buffer> <Enter> <ScriptCmd>FzfGrepDeal()<CR>
        },
        (map) => {
            return $'>>>>>>>>>>>>>>>>>>>>>>>>>>FzfGrepWords:{map.project_root}%'
        }
    )

    FzfGrepRun = () => fzf_grep.Toggle()
    nmap <Plug>FzfNativeGrep <ScriptCmd>FzfGrepRun()<CR>
    command! FzfGrep FzfGrepRun()
enddef

var FzfRecentFilesRun = null_function
var FzfRecentFilesDeal = null_function
def FzfRecentFilesSetup()
    var fr = fzn.FzfNative.new(
        (map, MarkUpdate) => {
            return {msglist: (filereadable(FILE_HISTORY_PATH) ? readfile(FILE_HISTORY_PATH) : [])}
        },
        (map) => {
            FzfRecentFilesDeal =  () => {
                var input = getline(".")
                FzfRecentFilesRun()
                exe $'edit {input}'
            }
            nmap <buffer> <Enter> <ScriptCmd>FzfRecentFilesDeal()<CR>
        },
        (map) => {
            return '::::::::::>>>>>>>>Oldfiles:'
        }
    )

    FzfRecentFilesRun = () => fr.Toggle()
    nmap <Plug>RecentFiles <ScriptCmd>FzfRecentFilesRun()<CR>
enddef

var GlobalTestLog = null_function
var DeleteLog = null_function
var RfreshLog = null_function
def TestLogPopuViewSetup()
    var logfile = (filereadable(G.LogfileName) ? readfile(G.LogfileName) : [])
    var ftl = fzn.FzfNativeSearch.new(
        (map, MarkUpdate) => null_dict,
        (map, input, Async, Mark) => ((input == '*') ? logfile : matchfuzzy(logfile, input))->reverse(),
        (map) => {
            DeleteLog = () => {
                writefile([], G.LogfileName, 's')
            }
            RfreshLog = () => {
                logfile = (filereadable(G.LogfileName) ? readfile(G.LogfileName) : [])
            }
            nnoremap <buffer> D <ScriptCmd>DeleteLog()<CR>
            nnoremap <buffer> R <ScriptCmd>RfreshLog()<CR>
        },
        (map) => '::::::::::>>>>>>>>TestLogFile:'
    )
    GlobalTestLog = () => ftl.Toggle()
    nnoremap <Plug>TestLogView <ScriptCmd>GlobalTestLog()<CR>
enddef

var HistorySaveRun = null_function
export def Setup()
    var recentfile_list: list<number> = []
    var RecentfileListAddCallback = (bufnr, bufmap) => {
        if bufmap->has_key(bufnr) | recentfile_list->remove(recentfile_list->index(bufnr)) | endif
        recentfile_list->add(bufnr)
    }
    add(listenner.buffer_read_callback_list, RecentfileListAddCallback)

    HistorySaveRun = () => FileHistorySave(recentfile_list)
    augroup LxdFileHistoryRecorder
        au!
        autocmd VimLeave * HistorySaveRun()
    augroup END
    FzfRecentFilesSetup()
    ProjectHistoryPopupSetup()

    FzfFuntionsSetup()
    FzfFilesSetup()
    FzfMapsSetup()
    FzfGrepSetup()

    ColorsSelectedAndSave()
    TestLogPopuViewSetup()
enddef
