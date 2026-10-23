if exists('b:current_syntax')
  finish
endif
syntax case match
" Synchronize from the start: a section-like line inside a raw fence is literal.
syntax sync fromstart
syntax match opensauceComment "#.*$"
syntax match opensauceLiteral "https\?://\S\+"
syntax match opensauceLiteral "!\[[^]]*\]([^)]*)"
syntax match opensauceOperator "?=\|-OR-\|[+=/]"
syntax match opensauceValue "\%(\w\|\.\)\@<!\%(\~\~\|\~\|!\)\?\d\+\%(\s\+\d\+/\d\+\|\%(\.\d\+\)\?\%(/\d\+\)\?\)\%(\s*\c\%(US fl oz\|US cups\?\|cups\?\|tbsp\|tsp\|kg\|mg\|ml\|lbs\?\|oz\|g\|l\|°\?[CF]\|h\|m\|s\)\>\)\?"
syntax match opensauceGroup "[\[\]]"
syntax match opensauceControl "^\s*\zs\%(Optional\|Meanwhile\|Repeat\)\ze\s*\["
syntax match opensauceResult "{[^}]*}"
syntax match opensauceVariant "[;:]\s*[^;:@,)#]\+" contained
syntax region opensauceProduct matchgroup=opensauceOperator start="@\s*[!~]\?" end="\ze[,)]\|$" contained oneline
syntax region opensauceQualifier start="," end="\ze)\|$" contained oneline contains=opensauceComment,opensauceLiteral
syntax region opensauceThing start="(" end=")\|$" oneline contains=opensauceVariant,opensauceProduct,opensauceQualifier,opensauceComment,opensauceLiteral
syntax region opensauceEquipment start="(" end=")\|$" contained oneline contains=opensauceVariant,opensauceProduct,opensauceQualifier,opensauceComment,opensauceLiteral
syntax region opensauceAction start="<\%(<\)\@!" end=">\|$" oneline contains=opensauceActionName,opensauceThing,opensauceResult,opensauceValue,opensauceOperator,opensauceComment,opensauceLiteral
syntax match opensauceActionName "<\@<=[^,>#]\+" contained
syntax match opensauceMetadata "^\s*[^:#]\+:" contained

" Section regions exclude normal code in prose, metadata and retained source.
syntax match opensauceSection "^\s*::[^#]*"
syntax region opensauceEquipmentSection matchgroup=opensauceSection start="^\s*::equipment\s*\ze\%(#\|$\)" end="^\ze\s*::" contains=opensauceEquipment,opensauceValue,opensauceOperator,opensauceComment,opensauceLiteral
syntax region opensauceRecipeSection matchgroup=opensauceSection start="^\s*::recipe\s*\ze\%(#\|$\)" end="^\ze\s*::" contains=opensauceMetadata,opensauceValue,opensauceComment,opensauceLiteral
syntax region opensauceProseSection matchgroup=opensauceSection start="^\s*::\%(story\|notes\)\s*\ze\%(#\|$\)" end="^\ze\s*::" contains=opensauceComment,opensauceLiteral
syntax region opensauceSourceSection matchgroup=opensauceSection start="^\s*::source\s*\ze\%(#\|$\)" end="^\ze\s*::" contains=opensauceRaw,opensauceComment,opensauceLiteral
" No keepend on the outer section: nested raw text may contain section headers.
syntax region opensauceRaw matchgroup=opensauceFence start="^<<<$" end="^>>>$" contained

highlight default link opensauceSection Keyword
highlight default link opensauceComment Comment
highlight default link opensauceLiteral Underlined
highlight default link opensauceOperator Operator
highlight default link opensauceValue Number
highlight default link opensauceGroup Delimiter
highlight default link opensauceControl Conditional
highlight default link opensauceResult Constant
highlight default link opensauceVariant Type
highlight default link opensauceProduct String
highlight default link opensauceQualifier Identifier
highlight default link opensauceThing Identifier
highlight default link opensauceEquipment Type
highlight default link opensauceAction Delimiter
highlight default link opensauceActionName Function
highlight default link opensauceMetadata Label
highlight default link opensauceRaw Normal
highlight default link opensauceFence Delimiter
let b:current_syntax = 'opensauce'
