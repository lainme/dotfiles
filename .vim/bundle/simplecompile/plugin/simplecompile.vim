"Description: A simple wrapper script for compling/running programs
"Author: lainme <lainme993@gmail.com>
"License: GPL V3.0

"Detect if loaded
if exists("g:loaded_simplecompile")
    finish
endif
let g:loaded_simplecompile = 1

"Default options
if !exists("g:simplecompile_debug")
    let g:simplecompile_debug = 0
endif

if !exists("g:simplecompile_terminal")
    let g:simplecompile_terminal = "xterm"
endif

"Define commands
command! SimpleCompile :call s:simpleCompile()
command! SimpleRun :call s:simpleRun()

"Compile
function! s:simpleCompile()
    "Save file
    exec "w"

    "Save old makeprg
    let s:oldmakeprg=&makeprg
    
    "Detect file type and set makeprg
    if &filetype == "fortran"
        setlocal makeprg=gfortran\ -ffree-line-length-0\ -o\ %<\ %\ -J\ /tmp
    elseif &filetype == "c"
        setlocal makeprg=gcc\ -o\ %<\ %
    elseif &filetype == "tex"
        setlocal makeprg=rubber\ -qpd\ %\ &&\ rubber\ --clean\ %
    else
        echo "Error: File type not supported for compile"
        return
    endif

    "Compile
    if g:simplecompile_debug == 1
        silent exec "make -g -Wall"
    else
        silent exec "make"
    endif

    "Restore makeprg
    let &makeprg=s:oldmakeprg
    
    "Redraw
    redraw!
endfunction

"Run
function! s:simpleRun()
    "Define two type of file list
    let s:binary = ["fortran","c"]
    let s:script = ["python"]
    
    "Run
    try
        if (index(s:binary, &filetype)>=0) 
            silent exec "!".g:simplecompile_terminal." -e bash -c \"cd %:p:h;./%:t:r;echo;read\" &"
        elseif (index(s:script, &filetype)>=0)
            silent exec "!".g:simplecompile_terminal." -e bash -c \"cd %:p:h;".&filetype." %:t;echo;read\" &"
        elseif &filetype == "tex"
            silent exec "!xdg-open %<.pdf &"
        endif
    catch
        echo "Error: not able to execute the file"
        return
    endtry
    
    "Redraw
    redraw!
endfunction
