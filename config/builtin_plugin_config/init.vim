vim9script
var SaveAndMark = null_function
var Quit = null_function
export def Setup()
    nmap ,p <Plug>ProjectHistoryPopup
    nmap ,c <Plug>ColorsPopupBrowser
    nmap ,r <Plug>RecentFiles
    nmap ,d <Plug>FZFFunctions
    nmap ,e <Plug>NetrwToggle
    nmap ,w <Plug>ToggleWorkSpace
    nmap ,f <Plug>FzfNative_Files
    nmap ,l <Plug>FzfNativeGrep
    nmap ,t <Plug>TestLogView
    nmap <leader>sc <Plug>ColorsSync
    nmap <leader>th <Plug>HortTerminalToggle
    nmap <leader>tv <Plug>VertTerminalToggle
    nmap <leader>te <Plug>ExternTerminal
    #nmap <leader>fd <Plug>FZFFunctions
    #nmap <leader>fw <plug>FzfNativeGrep

    SaveAndMark = () => {
        if !empty(getbufvar(bufnr(), '&bt')) | return | endif
        write
        exe "TriggerGitDiffMark"
    }
    Quit = () => {
        for bc in getbufinfo()
            if getbufvar(bc.bufnr, '&buftype') == 'prompt' | silent exe $"bwipeout! {bc.bufnr}" | endif
        endfor
        quitall
    }
    nmap <c-s> <ScriptCmd>SaveAndMark()<CR>
    nmap <c-q> <ScriptCmd>Quit()<CR>
	nmap <C-p> <Plug>FZFMaps

    nnoremap <C-/> <Plug>VertTerminalToggle
    tnoremap <C-/> <Plug>VertTerminalToggle

    nnoremap <C-\> <Plug>HortTerminalToggle
    tnoremap <C-\> <Plug>HortTerminalToggle

    nmap <F2> <Plug>HortTerminalCwdToggle
    tmap <F2> <Plug>HortTerminalCwdToggle
enddef
