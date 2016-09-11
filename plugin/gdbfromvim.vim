"
" GdbFromVim - A vim plugin to interact with GDB
" Copyright (C) 2012  Fernando Castillo
"
" This program is free software; you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation; either version 2
" of the License, or (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
"
if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

" TODO: Implement core dump support
" TODO: Implement attach pid support
" TODO: Implement python3 support

let s:gdblibNotFound = 0
let s:init = 0
let s:gdbConnected = 0
let s:app = ''
let s:args = ''
let s:gdbpath = ''
let s:log = 0

if exists("g:gdb_from_vim_path")
    let s:gdbpath = g:gdb_from_vim_path
endif

if exists("g:gdb_from_vim_log")
    let s:log = g:gdb_from_vim_log
endif

python << EOF
import vim
try:
    from gdblib.gdb import GDB
    import gdblib
    import logging
except Exception, e:
    vim.command("let s:gdblibNotFound = 1")
EOF

if s:gdblibNotFound == 1
    echo "Error: Gdblib not found, disabling GdbFromVim plugin"
    finish
endif

python << EOF

if vim.eval("s:log") == '1':
    gdblib.log.Logger.enable(True)
    gdblib.log.Logger.level(logging.DEBUG)
    gdblib.log.Logger.logToFile('gdb-from-vim.log')

class GdbFromVimUpdater():
    def newFileLocation(self, buf, line):
        vim.command("e " + buf);
        window = vim.current.window
        window.cursor = (int(line),1)
try:
    updater = GdbFromVimUpdater()
    gdb = GDB()
    if vim.eval("s:gdbpath") != '':
        gdb.gdbBinary(vim.eval("s:gdbpath"))
except Exception, e:
    print e
EOF

" Commands
command! -nargs=0 GdbFromVimClear call GdbFromVimClear()
command! -nargs=0 GdbFromVimAddBreakpoint call GdbFromVimAddBreakpoint()
command! -nargs=1 GdbFromVimDeleteBreakpoint call GdbFromVimDeleteBreakpoint(<f-args>)
command! -nargs=0 GdbFromVimDeleteAllBreakpoints call GdbFromVimDeleteAllBreakpoints()
command! -nargs=0 GdbFromVimPrintBreakpoints call GdbFromVimPrintBreakpoints()
command! -nargs=? GdbFromVimRun call GdbFromVimRun(<f-args>)
command! -nargs=0 GdbFromVimStep call GdbFromVimStep()
command! -nargs=0 GdbFromVimContinue call GdbFromVimContinue()
command! -nargs=0 GdbFromVimNext call GdbFromVimNext()
command! -nargs=1 GdbFromVimPrint call GdbFromVimPrint(<f-args>)
command! -nargs=0 GdbFromVimClose call GdbFromVimClose()
command! -nargs=1 GdbFromVimRemote call GdbFromVimRemote(<f-args>)
command! -nargs=1 -complete=file GdbFromVimTty call GdbFromVimTty(<f-args>)
command! -nargs=1 -complete=file GdbFromVimSymbolFile call GdbFromVimSymbolFile(<f-args>)
command! -nargs=1 -complete=file GdbFromVimGdbPath call GdbFromVimGdbPath(<f-args>)
command! -nargs=1 -complete=file GdbFromVimLoad call GdbFromVimLoad(<f-args>)

function! GdbFromVimLoad(symbol)
    if s:gdbConnected == 0
        return
    endif
python <<EOF
try:
    gdb.load(vim.eval("a:symbol"))
    print("Loaded symbol...")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimGdbPath(path)
python <<EOF
try:
    gdb.gdbBinary(vim.eval("a:path"))
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimRemote(host)
    call GdbFromVimInit()
    if s:gdbConnected == 1
        call GdbFromVimClose()
    endif
python <<EOF
try:
    gdb.connectRemote(vim.eval("a:host"))
    gdb.addNewFileLocationListener(updater)
    vim.command("let s:gdbConnected = 1")
    print("Gdb connected...")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimSymbolFile(symbol)
python <<EOF
try:
    gdb.symbolFile(vim.eval("a:symbol"))
    print("Added symbol...")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimTty(tty)
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python <<EOF
try:
    gdb.setTty(vim.eval("a:tty"))
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimInit()
    if s:init == 0
        au BufEnter * set cursorline 
        au VimLeavePre * call GdbFromVimClose()
        set cursorline
        let s:init = 1
    endif
endfunction

function! GdbFromVimOpen()
    call GdbFromVimInit()
    if s:gdbConnected == 1
        call GdbFromVimClose()
    endif
python << EOF
try:
    app = vim.eval("s:app")
    gdb.connectApp(app)
    gdb.addNewFileLocationListener(updater)
    vim.command("let s:gdbConnected = 1")
    print("Gdb connected...")
except Exception,e:
    print e
EOF
endfunction

function! PromptForProgram()
    if exists("g:gdb_from_vim_args")
        let s:args = g:gdb_from_vim_args
    endif
    if exists("g:gdb_from_vim_app")
        let s:app = g:gdb_from_vim_app
    endif
    if len(s:app) > 0
        return
    endif
    call inputsave()
    let l:input = input('GDBFromVim - enter program path: ', '', 'file')
    call inputrestore()

    if strlen(l:input) > 0
        let s:app = l:input
    endif
endfunction

function! GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        call PromptForProgram()
        call GdbFromVimOpen()
    endif
endfunction

function! GdbFromVimContinue()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.continueExecution()
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimAddBreakpoint()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    my = vim.current.buffer
    pos = vim.current.window.cursor
    gdb.addBreakpoint(my.name, int(pos[0]))
    print("Added breakpoint...")
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimClear()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    my = vim.current.buffer
    pos = vim.current.window.cursor
    gdb.clear(my.name, int(pos[0]))
    print("Cleared breakpoint...")
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimDeleteBreakpoint(number)
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.deleteBreakpoint(vim.eval("a:number"))
    print("Deleted breakpoint...")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimPrintBreakpoints()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
    call setqflist([])
python << EOF
try:
    breakpoints = gdb.getBreakpoints()
    
    for b in breakpoints:
        vim.command("let entry = {'filename' : '" + b.getSourceFile() + "', "+ 
        "'lnum' : '" + str(b.getLineNumber()) + "',"+ 
        "'text' : 'Breakpoint number: " +str(b.getNumber()) +"'}")
        vim.command("let qflist = getqflist()")
        vim.command("call add(qflist, entry)")
        vim.command("call setqflist(qflist)")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimDeleteAllBreakpoints()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.deleteAllBreakpoints()
    print("Deleted breakpoints...")
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimApplication(application)
    let g:GdbFromVimApp = a:application
endfunction


function! GdbFromVimRun(...)
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
    

    if a:0 > 0
        let s:args = a:1
    endif
python << EOF
try:
    gdb.run(vim.eval("s:args"))
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimStep()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.step()
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimNext()
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.next()
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimClose()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    gdb.removeNewFileLocationListener(updater)
    gdb.disconnect()
    print("Gdb closed...")
except Exception,e:
    print e
EOF
    let s:gdbConnected = 0
    let s:app = ''
    let s:args = ''
endfunction

function! GdbFromVimPrint(expression)
    call GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        return
    endif
python << EOF
try:
    exp = vim.eval('a:expression')
    print gdb.p(exp)
except Exception, e:
    print e
EOF
endfunction

