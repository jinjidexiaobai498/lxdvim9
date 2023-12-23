vim9script
#import './view.vim' as V
import './global.vim' as G
const __FILE__ = expand('<sfile>')
var debug = true
var Log = G.GetLog(debug, __FILE__)
var Info = G.GetLog(true, __FILE__)

var Assert = G.GetAssertTrue(__FILE__)

export class Buffer
	this.bufnr: number
	this.name: string
	this.changed: bool
	this.changedtick: number
	this.buf_changedtick: number
	this.hidden: bool
	this.lastused: number
	this.listed: bool
	this.loaded: bool
	this.lnum: number
	this.linecount: number # only valid when loaded
	this.windows: list<number>
	this.popups: list<number> 
	this.buf: list<any>
	this.is_sync = false
	this.is_buf_sync = false
	#sings: list<any>
	#this.variables: dict<any>
	
	def new(this.bufnr)
		Assert(this.Sync(), 'bufnr doesnot exists', this.bufnr)
		this.EndLine()
	enddef

	def BufSync(): bool
		if this.is_buf_sync 
			return true
		endif
		this.buf = getbufinfo(this.bufnr)
		if empty(this.buf)
			return false
		endif
		this.is_buf_sync = true
		return true
	enddef

	def Sync(): bool

		if this.is_sync
			return true
		endif

		if !this.BufSync()
			return false
		endif

		var p = this.buf[0]
		Log('Sync, this Buffer: ', this)
		this.bufnr		= p.bufnr
		this.changed	= p.changed
		this.changedtick = p.changedtick
		this.hidden		= p.hidden
		this.lastused	= p.lastused
		this.listed		= p.listed
		this.lnum		= p.lnum
		this.linecount	= p.linecount
		this.loaded		= p.loaded
		this.name		= p.name
		this.windows	= p.windows
		this.popups		= p.popups
		this.buf_changedtick = this.changedtick->copy()
		this.is_sync = true

		return true
	enddef

	def EndLine()
		this.is_sync = false
		this.is_buf_sync = false
	enddef

endclass

def Test()
	var b = Buffer.new(1)
	b.Sync()
	#echom getbufinfo(1)[0]->get('changedtick')
enddef

#Test()

