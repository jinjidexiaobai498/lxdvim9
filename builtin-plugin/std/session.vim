vim9script
import "./file.vim" as f
import "./project.vim" as p

export class Session
	static ID: number = 0
	static  DEFAULT_SAVE_DIR = &dir .. "/session"
	this.id: number
	this.filename: string
	this.save_dir: string
	this.path: string

	static def GetGenerateID(): number
		ID  = get(g:, '__session_generate_id__', 0) + 1
		g:__session_generate_id__ = ID
		return ID - 1
	enddef 

	def new(filename: string = null_string, save_dir: string = null_string)

		this.save_dir = (save_dir == null_string) ? DEFAULT_SAVE_DIR : save_dir

		if !isdirectory(this.save_dir)
			assert_true(mkdir(this.save_dir, 'p'))
		endif

		this.filename = filename
		this.path = this.GetSessionPath()

	enddef

	def SaveForce()
		exe "mksession! " .. this.path
	enddef

	def Save()
		exe "mksession " .. this.path
	enddef

	def GetSessionPath(): string
		return (this.save_dir .. "/" .. this.filename)
	enddef

endclass
