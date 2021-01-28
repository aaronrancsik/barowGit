" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowGitInit")
  finish
endif
let g:barowGitInit = 1

augroup barowGit
  autocmd!
  autocmd BufNewFile,BufReadPre,CursorHold,BufEnter * call barowGit#init(expand("<afile>:p:h"))
  autocmd User BarowGit call barow#update()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
