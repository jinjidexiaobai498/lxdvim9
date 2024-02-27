vim9script
import '../../builtin_plugin/std/global.vim' as global
var ProjectFindFile = null_function
var ProjectRg       = null_function
export def Setup()
	#find in loaded files
	nnoremap <leader>fl <Cmd>Lines<CR>
	nnoremap <leader>ft <Cmd>BTag<CR>

	#find in  work direcotry
	nnoremap <leader>fc <Cmd>Colors<CR>
	nnoremap <leader>fb <Cmd>Buffers<CR>
	nnoremap <leader>fT <Cmd>Tags<CR>

	# find by word under current cursor
    nnoremap <leader>fs <Cmd>exe $'BTag {expand("<cword>")}' <CR>
    nnoremap <leader>fS <Cmd>exe $'Tags {expand("<cword>")}' <CR>
    nnoremap <leader>fw <Cmd>exe $'BLines {expand('<cword>')}' <CR>
    nnoremap <leader>fW <Cmd>exe $'Lines {expand('<cword>')}' <CR>
    nnoremap <leader>fm <Cmd>Maps<CR>

    ProjectFindFile = () => {
        exe $'Files {global.GetProjectRoot()}'
    }
	nnoremap <leader>ff <ScriptCmd>ProjectFindFile()<CR>
    nnoremap ,F <ScriptCmd>ProjectFindFile()<CR>
	#nnoremap <leader>ff <Cmd>GFiles<CR>
    #nnoremap ,F <Cmd>GFiles<CR>
    nnoremap ,B <Cmd>Buffers<CR>
    nnoremap ,R <Cmd>History<CR>
    nnoremap <C-P> <Cmd>Maps<CR>
    if executable('rg')
        ProjectRg = (word) => {
                exe $'lcd {global.GetProjectRoot()}'
                exe $'RG {word}'
        }
        nnoremap <leader>fL <ScriptCmd>ProjectRg(expand("<cword>"))<CR>
        nnoremap ,L <ScriptCmd>ProjectRg(expand("<cword>"))<CR>
    endif
enddef
