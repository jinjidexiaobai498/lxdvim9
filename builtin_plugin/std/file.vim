vim9script

export class File
    var path: string
    var fullpath: string
    var directory: string
    var buffer: list<string>
    var len = 0
    var is_sync = true
    def new(file_path: string, init_content: list<string> = [''], is_created_flag = true)
        this.fullpath = fnamemodify(expand(file_path), ":p")
        this.directory = fnamemodify(this.fullpath, ":h")
        NewFile(file_path, init_content, is_created_flag)
        this.Sync()
    enddef

    def ContainsLine(str: string): bool
        return this.buffer->index(str) != -1
    enddef

    def IndexOf(str: string): number
        return this.buffer->index(str)
    enddef

    def Get(idx: number): string
        return this.buffer[idx]
    enddef

    def SetLines(lines: list<string>)
        this.buffer = lines->copy()
        this.is_sync = false
    enddef

    def Insert(idx: number, item: string)
        this.is_sync = false
        this.buffer->insert(item, idx)
    enddef

    def Set(idx: number, str: string)
        this.is_sync = false
        this.buffer[idx] = str
    enddef

    def Len(): number
        return this.len
    enddef

    def Append(str: string)
        this.is_sync = false
        this.buffer->add(str)
        this.len += 1
    enddef

    def Remove(idx: number): string
        this.is_sync = false
        return this.buffer->remove(idx)
    enddef

    def  Write()
        this.is_sync = true
        AssertTrue(WriteFile(this.fullpath, this.buffer), 'use def Write: failed : Object', this->string())
    enddef

    def Sync()
        if this.is_sync
            this.buffer = readfile(this.fullpath)
            this.len = len(this.buffer)
        else
            this.Write()
            this.is_sync = true
        endif
    enddef

    def GetLines(): list<string>
        return this.buffer->copy()
    enddef

endclass

export def WriteFile(path: string, buf: list<string>): bool
    if writefile(buf, path, 's') == 0 | return true | endif
    Info(' Write file:', path, 'failed , content: ', buf->string(), "")
    return false
enddef

export def CreateFile(path: string, init_content: list<string> = ['']): bool
    var pd = fnamemodify(path, ":p:h")
    if !isdirectory(pd) && !mkdir(pd, 'p') | return false | endif
    if !(WriteFile(path, init_content)) | return false | endif
    return true
enddef

export def NewFile(file_path: string, init_content: list<string> = [''], is_created_flag = true)
    var is_exsited = !(!filereadable(fnamemodify(expand(file_path), ":p")))
    if !is_exsited && is_created_flag | is_exsited = CreateFile(file_path, init_content) | endif
    AssertTrue(is_exsited, "EORROR path doesnot exist, path: " .. file_path)
enddef
