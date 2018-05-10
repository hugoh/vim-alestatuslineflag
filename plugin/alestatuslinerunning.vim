""
" @section Running flag, runningflag
" 
" Add |AleStatuslineRunning()| to your statusline to show
" |g:alestatusline_runningmsg| when ALE's linter is running. The setup is
" similar to the |AleStatuslineFlag()| setup.
"
" To disable this running flag, do: >
"     let g:alestatusline_running = 0
" <

""
" Default: 1
"
" Whether to redraw the statusline after ALE running status has changed; this
" is required to use |AleStatuslineRunning| in your statusline. If you don't
" use it, set it to 0. Note that it has to be set at load time.
let g:alestatusline_running = get(g:, 'alestatusline_running', 1)
 
if !g:alestatusline_running
  finish
endif

""
" Default: 'linting'
"
" Message to display with |AleStatuslineRunning()| when ALE is running.
let g:alestatusline_runningmsg = get(g:, 'alestatusline_runningmsg', 'linting')

function! AleStatuslineRunning()
  return s:ale_running ? g:alestatusline_runningmsg : ''
endfunction

let s:ale_running = 0
function! s:mark_ale_running(onoff)
  let s:ale_running = a:onoff
  redrawstatus
endfunction

augroup alestatuslinerunning_ag
  autocmd!
  autocmd User ALELintPre  call s:mark_ale_running(1)
  autocmd User ALELintPost call s:mark_ale_running(0)
augroup end
