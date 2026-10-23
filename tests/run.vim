set nocompatible
set nomore
let v:errmsg = ''
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
filetype plugin indent on
syntax on
execute 'edit ' . fnameescape(s:root . '/samples/example.opensauce')
call assert_equal('opensauce', &filetype)
call assert_equal('opensauce', b:current_syntax)
call assert_equal('# %s', &commentstring)
call assert_equal(':#', &comments)
call assert_match('<:>', &matchpairs)
call assert_notmatch('[tcro]', &formatoptions)
setlocal shiftwidth=4 expandtab

function! Group(text, needle, expected) abort
  let lnum = search('\V' . escape(a:text, '\'), 'nw')
  call assert_true(lnum > 0, 'Missing test line: ' . a:text)
  let col = match(getline(lnum), '\V' . escape(a:needle, '\')) + 1
  call assert_equal(a:expected, synIDattr(synID(lnum, col, 1), 'name'), a:text . ' / ' . a:needle)
endfunction
call Group('::ingredients', '::', 'opensauceSection')
call Group('(flour; plain)', 'flour', 'opensauceThing')
call Group('(flour; plain)', 'plain', 'opensauceVariant')
call Group('(egg: yolk)', 'yolk', 'opensauceVariant')
call Group('(gin; London dry @ ~Beefeater)', 'Beefeater', 'opensauceProduct')
call Group('(cocktail bitters @ !Peychaud', '@', 'opensauceOperator')
call Group('(mixing bowl)', 'mixing', 'opensauceEquipment')
call Group('{dough} <mix, in (mixing bowl)>', 'mix,', 'opensauceActionName')
call Group('{dough} <mix, in (mixing bowl)>', 'bowl', 'opensauceThing')
call Group('{cake} <bake, 180C>', '180', 'opensauceValue')
call Group('{cake} <bake, 180C>', 'cake', 'opensauceResult')
call Group('?= golden', '?=', 'opensauceOperator')
call Group('1 1/2 cups', '1 1/2', 'opensauceValue')
call Group('~10g', '~', 'opensauceValue')
call Group('~~100ml', '~~', 'opensauceValue')
call Group('-OR-', '-OR-', 'opensauceOperator')
call Group('# example', '#', 'opensauceComment')
call Group('https://example.org/recipe#original', '#original', 'opensauceLiteral')
call Group('Original source:', '(not', 'opensauceRaw')
call Group('Original source:', '#', 'opensauceRaw')
call Group('Optional [', 'Optional', 'opensauceControl')

" Use scratch buffers, never write changes to sample or corpus files.
enew!
setfiletype opensauce
call setline(1, ['::ingredients', '(gin @ !Brand: Special; Label, size @ literal) 2',
      \ '![alt # literal](photo#fragment)', '(unclosed', '(next) 2',
      \ '::story', '(prose) <words> 2', '::source', '<<<',
      \ '::ingredients', '(raw) # raw', '[', '>>>',
      \ '::instructions', '(back) <mix>', '<<<', '(normal)'])
syntax sync fromstart
call Group('Brand: Special', 'Special', 'opensauceProduct')
call Group('Brand: Special', '@ literal', 'opensauceQualifier')
call Group('![alt', '# literal', 'opensauceLiteral')
call Group('(next)', 'next', 'opensauceThing')
call Group('(prose)', 'prose', 'opensauceProseSection')
call Group('(raw)', 'raw', 'opensauceRaw')
call Group('(back)', 'back', 'opensauceThing')
call Group('(normal)', 'normal', 'opensauceThing')
call assert_equal(-1, OpenSauceIndent(11))

enew!
setfiletype opensauce
setlocal shiftwidth=4 expandtab
call setline(1, ['::instructions', 'Optional [', '(flour)', '    Meanwhile [',
      \ '    (water)', ']', ']', '    <rest>', '', '::source', '<<<', '[', '(raw)', '>>>'])
normal! gg=G
call assert_equal('    (flour)', getline(3))
call assert_equal('        (water)', getline(5))
call assert_equal('    ]', getline(6))
call assert_equal(']', getline(7))
call assert_equal('    <rest>', getline(8), 'Preserve authored continuation')
call assert_equal('(raw)', getline(13), 'Preserve raw indentation')
call cursor(2, 1)
normal! $
normal! %
call assert_equal(7, line('.'), 'Standard % bracket match')
call cursor(2, 1)
execute "normal! o(test)\<Esc>"
call assert_equal('    (test)', getline(3), 'Real insert-mode group indentation')

" Undo buffer-local settings when changing filetype.
let s:undo = b:undo_ftplugin . ' | ' . b:undo_indent
execute s:undo
call assert_equal(&g:commentstring, &l:commentstring)
call assert_equal(&g:indentexpr, &l:indentexpr)


" New-file recognition and conservative handling of incomplete raw fences.
enew!
execute 'file ' . fnameescape(s:root . '/tests/new-recipe.opensauce')
doautocmd BufNewFile
call assert_equal('opensauce', &filetype)
call setline(1, ['::source', '<<<', '::ingredients', '(unclosed raw) # literal'])
syntax sync fromstart
call Group('(unclosed raw)', 'raw', 'opensauceRaw')
call assert_equal(-1, OpenSauceIndent(4))
enew!
setfiletype opensauce
call setline(1, ['::source', '  <<<', '(not fenced)', '::ingredients', '(normal)'])
syntax sync fromstart
call Group('(not fenced)', 'not', 'opensauceSourceSection')
call Group('(normal)', 'normal', 'opensauceThing')
enew!
setfiletype opensauce
setlocal shiftwidth=2
call setline(1, ['::instructions', '[', ']', '  <rest>'])
normal! gg=G
call assert_equal(']', getline(3), 'Empty group closure')
call assert_equal('  <rest>', getline(4), 'User indentation width retained')

let s:corpus = empty($OSF_CORPUS) ? s:root . '/../corpus' : $OSF_CORPUS
let s:recipes = ['examples/public-domain-recipes/ravioli/ravioli.opensauce',
      \ 'examples/public-domain-recipes/no-knead-bread/no-knead-bread.opensauce',
      \ 'examples/cocktail-specs/cointreau-margarita/cointreau-margarita.opensauce']
let s:tested = 0
for relative in s:recipes
  let path = s:corpus . '/' . relative
  if filereadable(path)
    execute 'edit! ' . fnameescape(path)
    call assert_equal('opensauce', &filetype, relative)
    let before = getline(1, '$')
    " Force syntax evaluation across the complete real document, including raw text.
    for n in range(1, line('$'))
      call synID(n, max([1, strlen(getline(n))]), 1)
    endfor
    call Group('::ingredients', '::', 'opensauceSection')
    if relative =~# 'ravioli'
      call Group('(egg, for dough)', 'egg', 'opensauceThing')
      call Group('(00 flour, for dough) 400 g', '400', 'opensauceValue')
    elseif relative =~# 'no-knead'
      call Group('(flour) 3 cups', '3 cups', 'opensauceValue')
      call Group('(oven)', 'oven', 'opensauceEquipment')
      call Group('(active dry yeast) 1.25/4tsp', '/4', 'opensauceValue')
    else
      call Group('(orange liqueur @ !Cointreau)', 'Cointreau', 'opensauceProduct')
      call Group('(lime: juice, fresh)', 'juice', 'opensauceVariant')
      call Group('<shake,', 'shake', 'opensauceActionName')
    endif
    call assert_equal(before, getline(1, '$'))
    let s:tested += 1
  elseif !empty($OSF_CORPUS)
    call assert_report('Missing requested corpus fixture: ' . path)
  endif
endfor
call assert_equal('', v:errmsg, 'No editor errors')
call writefile(v:errors + ['Corpus fixtures tested: ' . s:tested,
      \ empty(v:errors) ? 'PASS' : 'FAIL'], s:root . '/tests/results.log')
if !empty(v:errors)
  cquit
endif
qa!
