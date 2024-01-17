vim9script
import "./file.vim" as f
import "./project.vim" as p
import "./global.vim" as G

var debug = false
var Log = G.GetLog(debug)
var Info = G.GetLog(true)
var AssertTrue = G.GetAssertTrue('Session')

const DEFAULT_SAVE_DIR = &dir .. "/session"

export class Session
	static ID: number = 0
	this.id: number
	this.filename: string
	this.save_dir: string
	this.path: string

	static def GetGenerateID(): number
		ID  += 1
		return ID - 1
	enddef 

	def new(filename: string = null_string, save_dir: string = null_string)

		this.save_dir = empty(save_dir) ? DEFAULT_SAVE_DIR : save_dir

		if !isdirectory(this.save_dir)
			AssertTrue(mkdir(this.save_dir, 'p'))
		endif

		this.filename = filename
		this.path = [this.save_dir, this.filename]->join(G.Backslash)

	enddef

	def SaveForce()
		exe "mksession! " .. this.path
	enddef

	def Save()
		exe "mksession " .. this.path
	enddef

endclass
