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

" TODO: Restore values
" TODO: Implement show breakpoints
" TODO: Implement core dump support
" TODO: Implement attach pid support
" TODO: Implement python3 support

let s:gdbConnected = 0
python << EOF
import vim
from gdblib.gdb import GDB

class GdbFromVimUpdater():
    def newFileLocation(self, buf, line):
        vim.command("e " + buf);
        window = vim.current.window
        window.cursor = (int(line),1)

    def newContent(self, line):
       print line 
try:
    updater = GdbFromVimUpdater()
    gdb = GDB()
except Exception,e:
    print e
EOF

function! GdbFromVimOpen()
    au BufEnter * set cursorline 
    au VimLeavePre * call GdbFromVimClose()
    set cursorline
python << EOF
try:
    app = vim.eval("g:gdb_from_vim_app")
    args = vim.eval("g:gdb_from_vim_args")
    gdb.connectApp(app, args)
    gdb.addNewFileLocationListener(updater)
    gdb.addStandardOutputListener(updater)
    vim.command("let s:gdbConnected = 1")
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimOpenIfNeeded()
    if s:gdbConnected == 0
        call GdbFromVimOpen()
    endif
endfunction

function! GdbFromVimAddBreakpoint()
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    my = vim.current.buffer
    pos = vim.current.window.cursor
    gdb.addBreakpoint(my.name, int(pos[0]))

except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimClear()
    call GdbFromVimOpenIfNeeded()

python << EOF
try:
    my = vim.current.buffer
    pos = vim.current.window.cursor
    gdb.clear(my.name, int(pos[0]))

except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimDeleteBreakpoint(number)
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    gdb.deleteBreakpoint(vim.eval("a:number"))
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimPrintBreakpoints()
    call GdbFromVimOpenIfNeeded()
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
python << EOF
try:
    gdb.deleteAllBreakpoints()
except Exception, e:
    print e
EOF
endfunction

function! GdbFromVimApplication(application)
    let g:GdbFromVimApp = a:application
endfunction


function! GdbFromVimRun()
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    gdb.run()
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimStep()
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    gdb.step()
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimNext()
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    gdb.next()
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimClose()
python << EOF
try:
    gdb.disconnect()
    vim.command("let s:gdbConnected = 0")
except Exception,e:
    print e
EOF
endfunction

function! GdbFromVimPrint(expression)
    call GdbFromVimOpenIfNeeded()
python << EOF
try:
    exp = vim.eval('a:expression')
    print gdb.p(exp)
except Exception, e:
    print e
EOF
endfunction

