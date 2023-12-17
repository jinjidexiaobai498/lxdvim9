vim9script
import '../builtin-plugin/std/project.vim' as project
export def Setup()

	#find  in current buffer 
	nmap <leader>fl :Lines<CR> 
	nmap <leader>ft :BTag<CR>

	#find in  work direcotry
	nmap <leader>fc :Colors<CR>
	nmap <leader>fb :Buffers<CR>
	nmap <leader>fT :Tags<CR>
	nmap <leader>ff :call <SID>ProjectFindFile()<CR>

	if executable('rg')
		nmap <leader>fL :call <SID>ProjectRg()<CR>
	endif

	# find by word under current cursor 
	nmap <leader>fs :execute ":BTag " . expand('<cword>')<CR>
	nmap <leader>fS :execute ":Tags " . expand('<cword>')<CR>
	nmap <leader>fw :execute ":BLines " . expand('<cword>')<CR>
	nmap <leader>fW :execute ":Lines " . expand('<cword>')<CR>

	nmap <C-p> :Maps<CR>

	nmap ,f :call <SID>ProjectFindFile()<CR>
	nmap ,l :Lines<CR>
	nmap ,b :Buffers<CR>
	nmap ,r :History<CR>

	if executable('rg')
		nmap ,L :call <SID>ProjectRg()<CR>
	endif

enddef

def ProjectFindFile()
	var p = project.Project.new()
	exe 'Files ' .. p.project_path
enddef

def ProjectRg()
	var p = project.Project.new()
	exe 'lcd ' .. p.project_path
	exe 'RG'
enddef

#ProjectRg()
