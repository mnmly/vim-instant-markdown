" # Configuration
if !exists('g:instant_preview_slow')
    let g:instant_preview_slow = 0
endif

if !exists('g:instant_preview_autostart')
    let g:instant_preview_autostart = 1
endif

" # Utility Functions
" Simple system wrapper that ignores empty second args
function! s:system(cmd, stdin)
    if strlen(a:stdin) == 0
        call system(a:cmd)
    else
        call system(a:cmd, a:stdin)
    endif
endfu

function! s:refreshView()
    let bufnr = expand('<bufnr>')
    call s:system("curl -X PUT -T - http://localhost:8090/ &>/dev/null &",
                \ expand('%:p') . '----------'. s:bufGetContents(bufnr))
endfu

function! s:initDict()
    if !exists('s:buffers')
        let s:buffers = {}
    endif
endfu

function! s:pushBuffer(bufnr)
    call s:initDict()
    let s:buffers[a:bufnr] = 1
endfu

function! s:popBuffer(bufnr)
    call s:initDict()
    call remove(s:buffers, a:bufnr)
endfu

function! s:bufGetContents(bufnr)
  return join(getbufline(a:bufnr, 1, "$"), "\n")
endfu

" I really, really hope there's a better way to do this.
fu! s:myBufNr()
    return str2nr(expand('<abuf>'))
endfu

" # Functions called by autocmds
"
" ## push a new Preview buffer into the system.
"
" 1. Track it so we know when to garbage collect the daemon
" 2. Start daemon if we're on the first MD buffer.
" 3. Initialize changedtickLast, possibly needlessly(?)
fu! s:pushPreview()
    let bufnr = s:myBufNr()
    call s:initDict()
    call s:pushBuffer(bufnr)
    let b:changedtickLast = b:changedtick
endfu

" ## pop a Preview buffer
"
" 1. Pop the buffer reference
" 2. Garbage collection
"     * daemon
"     * autocmds
fu! s:popPreview()
    let bufnr = s:myBufNr()
    silent au! instant-preview * <buffer=abuf>
    call s:popBuffer(bufnr)
endfu

" ## Refresh if there's something new worth showing
"
" 'All things in moderation'
fu! s:temperedRefresh()
    if !exists('b:changedtickLast')
        let b:changedtickLast = b:changedtick
    elseif b:changedtickLast != b:changedtick
        let b:changedtickLast = b:changedtick
        call s:refreshView()
    endif
endfu

fu! s:previewPreview()
  aug instant-preview
    if g:instant_preview_slow
      au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
    else
      au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
    endif
    au BufWinLeave <buffer> call s:cleanUp()
  aug END
endfu

fu! s:cleanUp()
  au! instant-preview * <buffer>
endfu

if g:instant_preview_autostart
    " # Define the autocmds "
    aug instant-preview
        au! * <buffer>
        au BufEnter <buffer> call s:refreshView()
        if g:instant_preview_slow
          au CursorHold,BufWrite,InsertLeave <buffer> call s:temperedRefresh()
        else
          au CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:temperedRefresh()
        endif
        au BufWinLeave <buffer> call s:popPreview()
        au BufwinEnter <buffer> call s:pushPreview()
    aug END
else
    command! -buffer InstantPreviewPreview call s:previewPreview()
endif
