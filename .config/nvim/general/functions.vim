function ToggleLineNumbers()
    if &number && &relativenumber
        setlocal number norelativenumber
    elseif &number && !&relativenumber
        setlocal nonumber norelativenumber
    elseif !&number && !&relativenumber
        setlocal number relativenumber
    endif
endfunction

let g:windowmaximized = 0
function ToggleMaximizeWindow()
    if !g:windowmaximized
        execute "normal! \<C-W>_\<C-W>\<BAR>"
        let g:windowmaximized = 1
    elseif g:windowmaximized
        execute "normal! \<C-W>="
        let g:windowmaximized = 0
    endif
endfunction
