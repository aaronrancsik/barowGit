" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:barowGit')
  finish
endif
let g:barowGit = 1

let s:save_cpo = &cpo
set cpo&vim

let s:t = 0

function! s:out_cb(jobid, data, ...)
  if has('nvim')
    if !empty(a:data[0])
      let b:branchName = join(a:data)
    endif
  else
    let b:branchName = a:data
  endif
  doautocmd User BarowGit
endfunction

function! s:exit_cb(jobid, status, ...)
  if a:status != 0
    let b:branchName = ''
  endif
  doautocmd User BarowGit
endfunction

function! s:check_win_type()
  let info = getwininfo(win_getid())
  if !empty(&buftype)
        \|| &previewwindow == 1
        \|| &filetype =~# 'qf\|netrw'
        \|| info[0].loclist == 1
        \|| info[0].quickfix == 1
        \|| info[0].terminal == 1
    return 0
  endif
  return 1
endfunction

function! barowGit#branch()
  if !s:check_win_type()
    return ''
  endif
  if exists('b:branchName')
    return b:branchName
  else
    return ''
  endif
endfunction

function! barowGit#init(path)
  if !s:check_win_type()
    return
  endif
  let command = ['git', 'branch', '--show-current']
  if has('nvim')
    let options = {
          \ 'stdout_buffered': 1,
          \ 'on_stdout': function('s:out_cb'),
          \ 'on_exit': function('s:exit_cb')
          \ }
  else
    let options = {
          \ 'out_cb': function('s:out_cb'),
          \ 'exit_cb': function('s:exit_cb')
          \ }
  endif
  if isdirectory(a:path)
    let options.cwd = a:path
  endif
  if has('nvim')
    call jobstart(command, options)
  else
    call job_start(command, options)
  endif
endfunction

function! barowGit#cursor_hold(path)
  if !empty(s:t)
    let elapsed = reltimefloat(reltime(s:t, reltime()))
    if elapsed < 2
      return
    endif
  endif
  let s:t = reltime()
  call barowGit#init(a:path)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
