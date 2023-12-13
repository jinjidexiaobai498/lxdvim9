vim9script

def Test3()
	hi link Terminal Search
	var buf = term_start('/bin/bash', {hidden: 1, term_finish: 'close'})
	var winid = popup_create(buf, {minwidth: 50, minheight: 20})

enddef

def Test()
	var bufnr = bufadd('test')
	bufload(bufnr)
	setbufline(bufnr, 1, ['test'])
	var winid = popup_create(bufnr, {minwidth: 50, minheight: 20})
enddef

Test()
