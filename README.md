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
This command starts the execution of the program.

### GdbFromVimStep
This commands steps into a function.

### GdbFromVimNext
This commands pass over a function.

### GdbFromVimAddBreakpoint
This command adds a breakpoint in the current line.

### GdbFromVimDeleteBreakpoint
This command deletes the breakpoint specified by its number, it requires an argument, For example to delete the breakpoint 2:
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

## Configuration

### Setting the application to debug
        let g:gdb_from_vim_app = 'application'

### Settings the arguments for the application
        let g:gdb_from_vim_args = 'arguments'

## License
GdbFromVim is licensed under a GPL2 license. For more details see the LICENSE file.

## Bugs
If you find a bug please let me know by opening an issue at:
https://github.com/skibyte/gdb-from-vim/issues

## Credits
**Author:** Fernando Castillo skibyte@gmail.com
