"
" GDB from vim - A vim plugin to interact with GDB
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
" TODO: Change mappings
" TODO: Implement show breakpoints
" TODO: Implement delete breakpoint
" TODO: Implement delete all breakpoints
" TODO: Implement core dump support
" TODO: Implement attach pid support
" TODO: Implement python3 support

map <F4> :call VimGdbRun() <CR>
map <F5> :call VimGdbStep() <CR>
map <F6> :call VimGdbNext() <CR>
map <F7> :call VimGdbAddBreakpoint() <CR>
let s:gdbConnected = 0
python << EOF
import vim
from gdblib.gdb import GDB

class VimGdbUpdater():
    def newFileLocation(self, buf, line):
        vim.command("e " + buf);
        window = vim.current.window
        window.cursor = (int(line),1)

    def newContent(self, line):
       print line 
try:
    updater = VimGdbUpdater()
    gdb = GDB()
except Exception,e:
    print e
EOF

function! VimGdbOpen()
    au BufEnter * set cursorline 
    au VimLeavePre * call VimGdbClose()
    set cursorline
python << EOF
try:
    app = vim.eval("g:VimGdb_App")
    args = vim.eval("g:VimGdb_Args")
    gdb.connectApp(app, args)
    gdb.addNewFileLocationListener(updater)
    gdb.addStandardOutputListener(updater)
    vim.command("let s:gdbConnected = 1")
except Exception,e:
    print e
EOF
endfunction

function! VimGdbOpenIfNeeded()
    if s:gdbConnected == 0
        call VimGdbOpen()
    endif
endfunction

function! VimGdbAddBreakpoint()
    call VimGdbOpenIfNeeded()

python << EOF
try:
    my = vim.current.buffer
    pos = vim.current.window.cursor
    gdb.addBreakpoint(my.name, int(pos[0]))

except Exception,e:
    print e
EOF
endfunction

function! VimGdbApplication(application)
    let g:VimGdbApp = a:application
endfunction


function! VimGdbRun()
    call VimGdbOpenIfNeeded()
python << EOF
try:
    gdb.run()
except Exception,e:
    print e
EOF
endfunction

function! VimGdbStep()
    call VimGdbOpenIfNeeded()
python << EOF
try:
    gdb.step()
except Exception,e:
    print e
EOF
endfunction

function! VimGdbNext()
    call VimGdbOpenIfNeeded()
python << EOF
try:
    gdb.next()
except Exception,e:
    print e
EOF
endfunction

function! VimGdbClose()
python << EOF
try:
    gdb.disconnect()
    vim.command("let s:gdbConnected = 0")
except Exception,e:
    print e
EOF
endfunction

function! VimGdbPrint(expression)
    call VimGdbOpenIfNeeded()
python << EOF
try:
    exp = vim.eval('a:expression')
    print gdb.p(exp)
except Exception, e:
    print e
EOF
endfunction

