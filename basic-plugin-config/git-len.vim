vim9script
export def Setup()
	g:GIT_LENS_ENABLED = true

	g:GIT_LENS_CONFIG = {
		blame_prefix: '----', # default is four spaces
		#blame_highlight: 'YourHighlight', # Comment
		blame_wrap: false, # blame text wrap
		blame_empty_line: false, # Whether to blame empty line.
	}
enddef
