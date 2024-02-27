vim9script
export var buffer_read_callback_list = []
export var buffer_delete_callback_list = []
export var bufmap = {}

def CheckBufferNormalFile(bufnr: number): bool
    return (empty(getbufvar(bufnr, "&bt"))) && buflisted(bufnr)
enddef

def HandlerBufRead(bufnr: number)
    if !CheckBufferNormalFile(bufnr) | return | endif
    for F in buffer_read_callback_list | F(bufnr, bufmap) | endfor
    if !bufmap->has_key(bufnr) | bufmap[bufnr] = fnamemodify(bufname(bufnr), ":p") | endif
enddef

def HandlerBufDelete(bufnr: number)
    if !CheckBufferNormalFile(bufnr) || !bufmap->has_key(bufnr) | return | endif
    for F in buffer_delete_callback_list | F(bufnr, bufmap) | endfor
    if bufmap->has_key(bufnr) | bufmap->remove(bufnr) | endif
enddef

augroup Listenner
    au!
    au BufReadPost * HandlerBufRead(expand('<abuf>')->str2nr())
    au BufDelete * HandlerBufDelete(expand('<abuf>')->str2nr())
    au BufWipeout * HandlerBufDelete(expand('<abuf>')->str2nr())
augroup END
