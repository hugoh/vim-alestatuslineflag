""
" @section Running flag, runningflag
" 
" To use the running flag, do: >
"     let g:alestatusline_runningredraw = 1
" <
" and add |AleStatuslineRunning()| to your statusline, similar to the
" |AleStatuslineFlag()| setup.

""
" Default: 'linting'
"
" Message to display with |AleStatuslineRunning()| when ALE is running
let g:alestatusline_runningmsg = get(g:, 'alestatusline_runningmsg', 'linting')

""
" Default: 0
"
" Whether to redraw the statusline after ALE running status has changed; if
" you use |AleStatuslineRunning| in your statusline, you'll most likely want
" this on.
let g:alestatusline_runningredraw = get(g:, 'alestatusline_runningredraw')
 
function! AleStatuslineRunning()
  return s:ale_running ? g:alestatusline_runningmsg : ''
endfunction

let s:ale_running = 0
function! s:mark_ale_running(onoff)
    let s:ale_running = a:onoff
    if g:alestatusline_runningredraw
      redrawstatus
    endif
endfunction

augroup vimrc_ALEProgress
  autocmd!
  autocmd User ALELintPre  call s:mark_ale_running(1)
  autocmd User ALELintPost call s:mark_ale_running(0)
augroup end
