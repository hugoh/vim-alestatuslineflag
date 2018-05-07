""
" @section Introduction, intro
" This plugin is a port of `SyntasticStatuslineFlag()` for |ALE|. Some aspects
" are currently not supported.
"
" To use the statusline flag, this must appear in your |'statusline'| setting >
"     %{alestatusline#flag()}
" <
" Something like this could be more useful: >
"     set statusline+=%#warningmsg#
"     set statusline+=%{alestatusline#flag()}
"     set statusline+=%*
" <
" When syntax errors are detected a flag will be shown. The content of the flag
" is derived from the |g:alestatusline_format| option.
" 
" As an example, the |flagship| Vim plugin (https://github.com/tpope/vim-flagship) has its
" own mechanism of showing flags on the |'statusline'|. To allow |flagship|
" to manage this statusline flag add the following |autocommand| to
" your vimrc: >
"     autocmd User Flags call Hoist("window", 'alestatusline#flag')
" <

if exists('g:loaded_alestatusline')
  finish
endif
let g:loaded_alestatusline = 1

""
" Default: '[Syntax: line:%F (%t)]'
"
" Use this option to control what the syntastic statusline text contains. Several
" magic flags are available to insert information:
" - %e  - number of errors
" - %w  - number of warnings
" - %se - number of style errors
" - %sw - number of style warnings
" - %t  - total number of warnings and errors
" - %ne - [UNSUPPORTED] filename of file containing first error
" - %nw - [UNSUPPORTED] filename of file containing first warning
" - %N  - [UNSUPPORTED] filename of file containing first warning or error
" - %pe - [UNSUPPORTED] filename with path of file containing first error
" - %pw - [UNSUPPORTED] filename with path of file containing first warning
" - %P  - [UNSUPPORTED] filename with path of file containing first warning or error
" - %fe - line number of first error
" - %fw - line number of first warning
" - %F  - line number of first warning or error
" 
" Note that |AleStatuslineFlag| does not support width and alignment controls
" as |SyntasticStatuslineFlag| does.
" 
" All fields except {flag} are optional. A single percent sign can be given as
" "%%".
" 
" Several additional flags are available to hide text under certain conditions:
" - %E{...} - hide the text in the brackets unless there are errors
" - %W{...} - hide the text in the brackets unless there are warnings
" - %B{...} - hide the text in the brackets unless there are both warnings AND
"             errors
"
" These flags can't be nested.
" 
" Example: >
"     let g:alestatusline_format = "[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]"
" <
" `
" If this format is used and the current buffer has 5 errors and 1 warning
" starting on lines 20 and 10 respectively then this would appear on the
" statusline: >
"     [Err: 20 #5, Warn: 10 #1]
" <
"
" If the buffer had 2 warnings, starting on line 5 then this would appear: >
"     [Warn: 5 #2]
" <
let g:alestatusline_format = get(g:, 'alestatusline_format', '[Syntax: line:%F (%t)]')
 
" Heavily based on SyntasticLoclist.getStatuslineFlag()
" http://github.com/vim-syntastic/syntastic
" under WTFPL

""
" Returns ALE statusline flag per |g:alestatusline_format|
function! alestatusline#flag() abort

  let l:buffer = bufnr('')
  try
    let l:ale_counts = ale#statusline#Count(l:buffer)
  catch /E117/
    return ''
  endtry

  " From |ale#statusline#Count|:
  " `error`         -> The number of problems with type `E` and `sub_type != 'style'`
  " `warning`       -> The number of problems with type `W` and `sub_type != 'style'`
  " `info`          -> The number of problems with type `I`
  " `style_error`   -> The number of problems with type `E` and `sub_type == 'style'`
  " `style_warning` -> The number of problems with type `W` and `sub_type == 'style'`
  " `total`         -> The total number of problems.

  if !l:ale_counts.total
    return ''
  endif

  let l:template = get(g:, 'alestatusline_format', '')

  return alestatusline#_format(l:template, l:ale_counts, l:buffer)
endfunction

" Internal {{{

function! alestatusline#_format(template, ale_counts, buffer) abort

  let l:output = a:template

  "hide stuff wrapped in %E(...) unless there are errors
  let l:output = substitute(l:output, '\m\C%E{\([^}]*\)}', a:ale_counts.error ? '\1' : '' , 'g')

  "hide stuff wrapped in %W(...) unless there are warnings
  let l:output = substitute(l:output, '\m\C%W{\([^}]*\)}', a:ale_counts.warning ? '\1' : '' , 'g')

  "hide stuff wrapped in %B(...) unless there are both errors and warnings
  let l:output = substitute(l:output, '\m\C%B{\([^}]*\)}', (a:ale_counts.warning && a:ale_counts.error) ? '\1' : '' , 'g')

  let l:flags = {
      \ '%':  '%',
      \ 't':  a:ale_counts.total,
      \ 'e':  a:ale_counts.error,
      \ 'w':  a:ale_counts.warning,
      \ 'se': a:ale_counts.style_error,
      \ 'sw': a:ale_counts.style_warning,
      \ 'F':  (a:ale_counts.total ? alestatusline#_getAleLocListLine(a:buffer, '') : ''),
      \ 'fe': (a:ale_counts.error ? alestatusline#_getAleLocListLine(a:buffer, 'E') : ''),
      \ 'fw': (a:ale_counts.warning ? alestatusline#_getAleLocListLine(a:buffer, 'W') : ''),
      \ 'N':  '',
      \ 'P':  '',
      \ 'ne': '',
      \ 'pe': '',
      \ 'nw': '',
      \ 'pw': '' }

  let l:output = substitute(l:output, '\v\%([npfs][ew]|[NPFtew%])', '\=l:flags[submatch(1)]', 'g')

  return l:output
endfunction

function! alestatusline#_getAleLocListLine(buffer, type) abort
  return alestatusline#_getFirstLoc(ale#engine#GetLoclist(a:buffer), a:type)
endfunction

function! alestatusline#_getFirstLoc(loclist, type) abort
  for l:pb in a:loclist
    if a:type ==# '' || l:pb.type ==# a:type
      return l:pb.lnum
    endif
  endfor
  return 0
endfunction

" }}}
