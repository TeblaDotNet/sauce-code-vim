if exists('b:did_indent')
  finish
endif
let b:did_indent = 1
setlocal autoindent
setlocal indentexpr=OpenSauceIndent(v:lnum)
setlocal indentkeys=o,O,0]
let b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys<'

if exists('*OpenSauceIndent')
  finish
endif

function! OpenSauceIndent(lnum) abort
  " Track only explicit group boundaries and raw fences, never recipe semantics.
  let section = ''
  let raw = 0
  let stack = []
  let opening = '^\s*\%(\%(Optional\|Meanwhile\|Repeat\)\s*\)\?\[\s*\%(#.*\)\?$'
  for n in range(1, a:lnum - 1)
    let text = getline(n)
    if raw
      if text ==# '>>>'
        let raw = 0
      endif
      continue
    endif
    if text =~# '^\s*::'
      let section = matchstr(text, '^\s*::\zs\S\+')
      let stack = []
    elseif section ==# 'source' && text ==# '<<<'
      let raw = 1
    elseif text =~# opening
      call add(stack, indent(n))
    elseif text =~# '^\s*\]\s*\%(#.*\)\?$' && !empty(stack)
      call remove(stack, -1)
    endif
  endfor
  if raw || index(['source', 'story', 'notes', 'recipe'], section) >= 0
    return -1
  endif
  if getline(a:lnum) =~# '^\s*\]\s*\%(#.*\)\?$' && !empty(stack)
    return stack[-1]
  endif
  let previous = prevnonblank(a:lnum - 1)
  if previous > 0 && getline(previous) =~# opening
    return indent(previous) + shiftwidth()
  endif
  " Keep authored continuations; on a new empty line inherit normal autoindent.
  return getline(a:lnum) =~# '^\s*$' && previous > 0 ? indent(previous) : -1
endfunction
