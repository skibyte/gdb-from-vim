# GDBFromVim
This pluging lets you debug your applications with gdb from vim, there is no
need to open a gdb instance like other plugins do.
Gdbfromvim relies on gdblib which spawns its own gdb instance.

## Requirements
* GdbFromVim requires Vim 7.3+ compiled with Python support.
* Python 2.6+
* Gdblib - https://github.com/skibyte/gdblib 
* Gdb with MI support

## Usage
In order to make easier handling GdbFromVim you might find these mappings handy:

    nnoremap <F4> :GdbFromVimRun <CR>
    nnoremap <F5> :GdbFromVimStep <CR>
    nnoremap <F6> :GdbFromVimNext <CR>
    nnoremap <F7> :GdbFromVimAddBreakpoint <CR>
    nnoremap <F8> :GdbFromFromDeleteBreakpoint <CR>
    nnoremap <F9> :GdbFromVimClear <CR>

### GdbFromVimRun
This command starts the execution of the program. Arguments can be passed to it.

### GdbFromVimStep
This commands steps into a function.

### GdbFromVimNext
This command pass over a function.

### GdbFromVimContinue
This command continues with the execution of the program, this command is also
used to start remote debugging.

### GdbFromVimAddBreakpoint
This command adds a breakpoint in the current line.

### GdbFromVimDeleteBreakpoint
This command deletes the breakpoint specified by its number, it requires an
argument, For example to delete the breakpoint number 2:
    GdbFromVimDeleteBreakpoint 2 

### GdbFromVimDeleteAllBreakpoints
This command deletes all the breakpoints previously set.

### GdbFromVimClear
This commands deletes the breakpoint in the current line.

### GdbFromVimPrint
This command prints the value of a variable, it requires an argument, For example:
    GdbFromVimPrint point->x

### GdbFromVimPrintBreakpoints
This command prints all the breakpoints set in the application, the values are printed in the quickfix list.

### GdbFromVimClose 
Closes the current gdb connection, this command might be used if you want to change 
the application to debug at runtime.

### GdbFromVimTty 
This command is used to redirect the IO to the specified tty passed as argument.

### GdbFromVimRemote 
This command is used to perform remote debugging, it receives as argument the
host and its port:

    GdbFromVimRemote 127.0.0.1:1234

### GdbFromVimSymbolFile 
Adds the symbol file passed as argument to gdb.

## Configuration

### Setting the application to debug
        let g:gdb_from_vim_app = 'application'

If this variable is not defined GdbFromVim will prompt for user input.

### Setting the arguments for the application
        let g:gdb_from_vim_args = 'arguments'

### Setting the gdb path
        let g:gdb_from_vim_path = '/usr/bin/gdb'

If arguments are passed to GdbFromVimRun the value of this variable are overriden.

## License
GdbFromVim is licensed under a GPL2 license. For more details see the LICENSE file.

## Bugs
If you find a bug please let me know by opening an issue at:
https://github.com/skibyte/gdb-from-vim/issues

## Credits
**Author:** Fernando Castillo skibyte@gmail.com
