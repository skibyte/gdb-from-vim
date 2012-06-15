# GDBFromVim
This pluging lets you debug your applications with gdb from vim, there is no
need to open a gdb instance like other plugins do.
Gdbfromvim relies on gdblib which spawns its own gdb instance.

## Requirements
* Gdb from vim requires Vim 7.3+ compiled with Python support.
* Python 2.4+
* Gdblib - https://github.com/skibyte/gdblib 

## Usage
In order to make easier handling GdbFromVim you might find these mappings handy:

    nnoremap <F4> :call GdbFromVimRun() <CR>
    nnoremap <F5> :call GdbFromVimStep() <CR>
    nnoremap <F6> :call GdbFromVimNext() <CR>
    nnoremap <F7> :call GdbFromVimAddBreakpoint() <CR>
    nnoremap <F8> :call GdbFromFromDeleteBreakpoint() <CR>
    nnoremap <F9> :call GdbFromVimClear() <CR>

### GdbFromVimRun

### GdbFromVimStep

### GdbFromVimNext

### GdbFromVimAddBreakpoint

### GdbFromVimDeleteBreakpoint

### GdbFromVimClear

### GdbFromVimPrint

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
