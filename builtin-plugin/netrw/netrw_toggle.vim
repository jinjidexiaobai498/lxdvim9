vim9script
import '../../std/view.vim' as view

def Open()
	exe ":20 Sexplore!"
enddef

var netrw = view.SimpleToggleView.new(Open)
var Run = () => netrw.Toggle()

export def Setup()
	nmap <Plug>NetrwToggle :call <SID>Run()<CR>
enddef

def Test()
	Setup()
	nmap <C-x> <Plug>NetrwToggle
	tnoremap <C-x> <Plug>NetrwToggle
	echo netrw
enddef
#Test()
