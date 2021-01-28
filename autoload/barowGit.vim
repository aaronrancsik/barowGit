" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowGit")
  finish
endif
let g:barowGit = 1

let b:job = 0

function! s:OnEvent(job_id, data, event) dict
  if a:event == 'stdout'
    let b:branchName = a:data
  elseif a:event == 'stderr'
    echom 'stderr: '.join(a:data)
  elseif a:data != 0
    let b:branchName = ""
  endif
  doautocmd User BarowGit
endfunction

function barowGit#branch()
  if exists("b:branchName")
    return b:branchName
  else
    return ""
  endif
endfunction

function barowGit#init(path)
  let command = ['git', 'branch', '--show-current']
  let options = {
        \ 'stdout_buffered': 1,
        \ 'stderr_buffered': 1,
        \ 'on_stdout': function('s:OnEvent'),
        \ 'on_stderr': function('s:OnEvent'),
        \ 'on_exit': function('s:OnEvent')
        \ }
  if !empty(a:path)
    let options.cwd = a:path
  endif
  let b:job = jobstart(command, options)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
