if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1
setlocal comments=:# commentstring=#\ %s
setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o
setlocal matchpairs+=<:>
let b:undo_ftplugin = 'setlocal comments< commentstring< formatoptions< matchpairs<'
