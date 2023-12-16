vim9script
import './global.vim' as G
export var debug = false
var info = true
var Log = G.GetLog(debug)
var Info = G.GetInfo(info)

export class Deque
	static RESERVE_RATE: float = 1.6
	this.capacity = 0
	this.len = 0
	this.data: list<any>
	this.front = 0
	this.back = 0
	this.is_changed = false
	this.buf_lines: list<any> = []

	def new(capacity: number = 0)
		this.data = repeat([null], capacity)
		this.capacity = capacity->copy()
	enddef

	def newDeque(cl: list<any>)
		this.data = cl->copy()
		this.len = this.data->len()
		this.back = this.len
		this.capacity = this.len
		this.is_changed = true
	enddef

	def Remove(idx: number): any

		var i = this.TransIndex(idx)

		this.len -= 1

		this.capacity -= 1

		this.is_changed = true

		if i < this.back

			this.back -= 1

		endif

		if i < this.front

			this.front -= 1

		endif

		this.back = this.back % this.capacity

		this.front = this.front % this.capacity

		return this.data->remove(i)

	enddef

	#def RemoveList(idx: number, end: number = -1): any
	#var res: any = null
	#var i = this.TransIndex(idx)
	#var endi = this.TransIndex(end)
	#var diss = 0
	#if i < endi
	#diss = (endi - i + 1)
	#res = this.data->remove(i, endi)
	#else
	#diss = (endi + this.len - i + 1)
	#res = this.data->remove(i, -1)
	#res->extend(this.data->remove(0, endi))
	#endif
	#this.len -= diss
	#this.capacity -= diss
	#this.is_changed = true
	#return res
	#enddef

	def GetList(): list<any>

		if !this.is_changed 
			return this.buf_lines->copy()
		endif

		Log('font and back: ' .. this.front .. " " .. this.back)
		if this.front <= this.back && this.len != this.capacity
			this.buf_lines = this.data->slice(this.front, this.back)->copy()
		else
			#Log('res: ' .. res->string())
			this.buf_lines = this.data->slice(this.front)->copy()
			this.buf_lines->extend(this.data->slice(0, this.back)->copy())
		endif
		this.is_changed = false
		return this.buf_lines->copy()
	enddef

	def Clear()
		this.len = 0
		this.front = 0
		this.back = 0
	enddef

	def Reserve(capacity: number): bool
		Log("Reserve Deque")
		assert_true(this.capacity <= capacity, "不支持缩小，请直接重新创建 Deque")

		var diss = capacity - this.capacity
		var apd = repeat([null], diss)

		assert_true(apd != null && apd->len() != 0, "Requset new Memory failed")

		this.data = this.data->extendnew(apd)
		assert_true(this.data != null, "Requset new Memory failed")
		Log("capacity of list   :" .. this.data->len())

		var old_capa = this.capacity->copy()
		this.capacity = capacity->copy()

		if this.back >= this.front && this.len != old_capa
			return true
		endif

		var i = capacity - 1
		var old_i = old_capa - 1
		var old_front = this.front->copy()
		Log('this.front: ' .. this.front)
		this.front += diss

		while old_i >= old_front
			this.data[i] = this.data[old_i]
			#this.data[i] = null
			i -= 1
			old_i -= 1
		endwhile

		return true

	enddef
	def Is_full(): bool
		return this.len == this.capacity
	enddef

	def AutoAppend()
		assert_true(this.Reserve(float2nr(ceil(this.capacity * RESERVE_RATE))), '拓展队列失败！')
	enddef

	def MemCheckAndAutoAdjust()
		if this.Is_full()
			Log("队列已满，扩展队列")
			this.AutoAppend()
		endif
	enddef

	def PushBackList(elist: list<any>)
		for i in elist
			this.PushBakc(i)
		endfor
	enddef

	def PushFrontList(elist: list<any>)
		for i in elist
			this.PushFront(i)
		endfor
	enddef

	def PushBack(elem: any): number
		this.MemCheckAndAutoAdjust()
		this.data[this.back] = elem->copy()
		this.back = (this.back + 1) % this.capacity
		this.len += 1
		this.is_changed = true
		return (this.back - 1)->copy()
	enddef

	def PopFront(): any
		assert_true(this.len != 0)
		if this.len == 0
			return null
		endif

		var res = this.Front()
		#this.data[this.front] = null
		this.front = (this.front + 1) % this.capacity
		this.is_changed = true
		return res
	enddef

	def Front(): any
		return this.data[this.front]->copy()
	enddef

	def Back(): any
		return this.data[this.back - 1]->copy()
	enddef

	def PushFront(elem: any): number
		this.MemCheckAndAutoAdjust()
		this.front = (this.front - 1 + this.capacity) % this.capacity
		this.data[this.front] = elem->copy()
		this.len += 1
		this.is_changed = true
		return this.front->copy()
	enddef

	def MinusOne(back_or_front = true)
		if back_or_front 
			this.back = (this.back - 1 + this.capacity) % this.capacity
		else
			this.front = (this.front - 1 + this.capacity) % this.capacity
		endif
	enddef

	def PlusOne(back_or_front = true)
		if back_or_front
			this.front = (this.front + 1) % this.capacity
		else
			this.back = (this.back + 1) % this.capacity
		endif
	enddef
	def CheckIndex(index: number): bool 
		if index > this.len || index + this.len < 0
			Log("out of index")
			return false
		endif
		return true
	enddef
	def TransIndex(index: number): number
		assert_true(this.CheckIndex(index), 'At TransIndex, invalid index')
		var res = index->copy()
		if index < 0
			res = (index + this.back + this.capacity) % this.capacity
		else
			res = (index + this.front) % this.capacity
		endif
		Log("TransIndex of input: " .. index .. " is : " .. res)
		return res
	enddef

	def Get(index: number): any
		return this.data[this.TransIndex(index)]->copy()
	enddef

	def Set(index: number, val: any)
		this.data[this.TransIndex(index)] = val->copy()
		if !this.is_changed
			this.buf_lines[index] = val->copy()
		else
			this.is_changed = true
		endif
	enddef

	def PrintProto()
		Log('Print Proto')
		echom this->string()
	enddef

	def Len(): number
		return this.len->copy()
	enddef

endclass

def TestDeque()
	var dq = Deque.new(10)
	dq.PushBack("hello world pb1")
	dq.PushFront("pf2")
	dq.PushFront('pffffffffffffffffff3')
	dq.PushFront('pffffffffffffffffff44444444')
	dq.PushFront('pffffffffffffffffff55555555')
	#dq.PrintProto()
	var i = 0
	while i < 100
		dq.PushBack(" " .. i)
		i += 1
	endwhile

	assert_true(dq.Len() == 102, "dq的长度不正确")

	var str = "test 2000000000000000000000"
	dq.Set(20, str)
	var res = dq.Get(20)
	assert_true(res == str)

	var l = dq.GetList()
	echom l->string()
	#dq.PrintProto()

	dq.Remove(20)
	dq.Remove(0)
	dq.Remove(-1)
	dq.Remove(-1)

	#dq.PrintProto()
	var x = dq.GetList()
	echom 'x : ' .. x->string()

enddef

#TestDeque()
#Test2()
