vim9script
# terminal.vim - A simple terminal plugin for Vim

var terminal_plugin = {}
var termianl_list = ['gnome-terminal', 'wezterm', 'alacritty', 'xterm', 'uxterm', 'kgx']

def TerminalInit()

	if terminal_plugin->has_key('Commands')
		return
	endif

	terminal_plugin.Commands = {
		open: (args) => {
			system('gnome-terminal --working-directory=' .. getcwd() .. ' ' .. args[0])
		}

	}
enddef

def TerminalRun(command: string)
	TerminalInit()
	terminal_plugin.Commands['open'](command)
enddef

TerminalRun('ls')
