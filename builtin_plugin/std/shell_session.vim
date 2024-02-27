vim9script noclear
import './global.vim' as G
var EmptyFunc   = (msg) => v:none
var DealOutput  = EmptyFunc
var DealError   = EmptyFunc
var shell_job   = job_start(
    &shell,
    {
        out_mode: 'raw',
        err_mode: 'raw',
        out_cb: (chl, msg) => DealOutput(msg),
        err_cb: (chl, msg) => DealError(msg)
    }
)

export def Execute(cmd: string, OutFunc: func = null_function, ErrorFunc: func = null_function )
    DealError  = !ErrorFunc ? EmptyFunc : ErrorFunc
    DealOutput = !OutFunc ? EmptyFunc : OutFunc
    ch_sendraw(shell_job, $"{cmd} \n")
    if !G.UseWindows | ch_sendraw(shell_job, $"clear \n") | endif
enddef
