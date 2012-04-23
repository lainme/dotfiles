"简单的编译/调试编译/运行插件
"作者：lainme <lainme993@gmail.com>
"协议：GPL V3.0

"检查是否加载
if exists("g:loaded_simplecompile")
    finish
endif
let g:loaded_simplecompile = 1

if !exists("g:SimpleDebugOn")
    let g:SimpleDebugOn = 0
endif

"定义命令
command! SimpleCompile :call s:simpleCompile()
command! SimpleRun :call s:simpleRun()

"编译
function! s:simpleCompile()
    "先保存文件
    exec "w"

    "保存makeprg值
    let s:oldmakeprg=&makeprg
    
    "检查文件类型，设定编译参数
    if &filetype == "fortran"
        setlocal makeprg=gfortran\ -ffree-line-length-0\ -o\ %<\ %\ -J\ /tmp
    elseif &filetype == "c"
        setlocal makeprg=gcc\ -o\ %<\ %
    elseif &filetype == "python"
        setlocal makeprg=python\ %
    elseif &filetype == "tex"
        call s:simpleSilent("!xterm -e bash -c \"cd %:p:h;xelatex %:t\" &")
        return
    else
        echo "错误：不支持的文件类型，或者不是可编译的文件"
        return
    endif

    "进行编译
    if g:SimpleDebugOn == 1
        call s:simpleSilent("make -g -Wall")
    else
        call s:simpleSilent("make")
    endif

    "还原makeprg值
    let &makeprg=s:oldmakeprg
endfunction

"运行
function! s:simpleRun()
    try
        if &filetype == "fortran" || &filetype == "c"  
            call s:simpleSilent("!xterm -e bash -c \"cd %:p:h;./%:t:r;echo;read\" &")
        elseif &filetype == "python"
            call s:simpleSilent("!xterm -e bash -c \"cd %:p:h;python %:t;echo;read\" &")
        elseif &filetype == "tex"
            call s:simpleSilent("!evince %<.pdf &")
        endif
    catch
        echo "错误：无法执行文件"
        return
    endtry
endfunction

"定义Silent函数，自动刷新
function! s:simpleSilent(cmdstring)
    exec "silent ".a:cmdstring
    exec "redraw!"
endfunction
