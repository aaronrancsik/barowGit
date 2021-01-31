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
  if a:event == 'stdout' && !empty(a:data[0])
    let b:branchName = join(a:data)
  elseif a:event == 'exit' && a:data != 0
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
  if &filetype == 'help' || &filetype == 'qf' || getwininfo(win_getid())[0].terminal == 1
    return
  endif
  let command = ['git', 'branch', '--show-current']
  let options = {
        \ 'data_buffered': 1,
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
