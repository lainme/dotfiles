"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"全局设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible "运行于非兼容模式
set mouse=a "鼠标
set number "显示行号
set showmatch "显示匹配的括号
set showcmd "显示未完成的命令
set wildmenu "按<tab>时命令补全 
set autoindent smartindent "智能缩进
set whichwrap=b,s,<,>,[,] "设置回绕键 
set incsearch hlsearch ignorecase smartcase "搜索设置
set winaltkeys=no "alt键不用于菜单
set cursorline "高亮当前行
set backspace=indent,eol,start "允许用退格删除字符
set completeopt=longest,menuone "补全设置
set foldmethod=indent "默认的缩进模式
set title "动态标题
set cmdheight=2 "设置命令栏高度
set tags=tags; "ctags设置
set sessionoptions=buffers,sesdir,folds,tabpages,winsize "session设置
set encoding=utf-8 
set fileencodings=ucs-bom,utf-8,gbk
set autochdir "自动切换路径
let mapleader="," "设置leader键
colorscheme lucius "配色主题

"终端下的一些设置
if ! has("gui_running")
    "修复ALT键
    for i in range(97,122)
        let c = nr2char(i)
        exec "set <M-".c.">=\<Esc>".c
    endfor
    set ttimeoutlen=50

    "避免终端退出时乱码
    set t_fs=(B
    set t_IE=(B
endif

"状态栏设置
set laststatus=2
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P 

"备份设置
set backup
set backupdir=/tmp 

"用四个空格代替<tab>
set expandtab smarttab
set shiftwidth=4 
set softtabstop=4 

"重置光标到上次会话的位置
autocmd BufReadPost * 
    \if line("'\"") > 0 && line("'\"") <= line("$") |
        \exe "normal g`\"" |
    \endif

"折叠的键映射
noremap <M-z> zc
noremap <M-x> zO
inoremap <M-z> <C-o>zc
inoremap <M-x> <C-o>zO

"光标移动
noremap <up> gk
noremap <down> gj
inoremap <up> <C-o>gk
inoremap <down> <C-o>gj

"在窗口间移动
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l
noremap <C-j> <C-w>j
noremap <C-k> <C-k>k

"quickfix设置
autocmd QuickFixCmdPost * :cw
noremap <Leader>ff :cn<CR>
noremap <Leader>fd :cp<CR>
noremap <Leader>fo :copen<CR>
noremap <Leader>fc :ccl<CR>

"GVIM的一些设置
if has("gui_running")
    set guioptions=a  "去掉菜单等，自动复制选择的区域
    set guicursor=a:blinkwait600-blinkoff600-blinkon600 "光标闪烁频率
    set guifont=Monospace\ 11
endif

"缓冲区移动键映射
noremap <M-left> :bprev!<CR>
noremap <M-right> :bnext!<CR>
inoremap <M-left> <ESC>:bprev!<CR>
inoremap <M-right> <ESC>:bnext!<CR>

"TAG跳转
nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"工具
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"在当前文件路径打开终端
noremap <F7> :!xterm -e bash -c "cd %:p:h;bash" &<CR> | :redraw!
inoremap <F7> <C-o>:!xterm -e bash -c "cd %:p:h;bash" &<CR> | :redraw!

"生成ctags
if ! exists("g:TagCmd")
    let g:TagCmd='ctags -R -o %:p:h/tags %:p:h'
endif

noremap <F8> :exec "silent !".g:TagCmd." &\n redraw!"<CR>
inoremap <F8> <ESC>:exec "w \n silent !".g:TagCmd." &\n redraw!"<CR>

"vimgrep搜索当前工作路径
function! ProjGrep()
    if ! exists("g:SearchPath")
        let g:SearchPath='**'
    endif

    let s:pattern=input("查询模式:")
    if s:pattern == ""
        return
    endif 
    let s:path=input("查询路径：",g:SearchPath)
    
    exec "vimgrep /".s:pattern."/j ".s:path
endfunction

noremap <F9> :call ProjGrep()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"插件设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------Vundle----------
"required
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

"script used
Bundle 'Tagbar'
Bundle 'neocomplcache'
Bundle 'The-NERD-Commenter'
Bundle 'buftabs'
Bundle 'po.vim'
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'TeX-PDF'
Bundle 'git://github.com/lainme/simplecompile.git'
"
"----------tagbar----------
let g:tagbar_left = 1
let g:tagbar_autofocus = 1
let g:tagbar_compact = 1
noremap <F3> :TagbarToggle<CR>
inoremap <F3> <ESC>:TagbarToggle<CR>

"----------NeoComplCache----------
let g:neocomplcache_enable_at_startup = 1 
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1

"----------NERD_commenter----------
let g:NERDShutUp=1
nmap <F4> ,c<space>
vmap <F4> ,c<space>
imap <F4> <C-o>,c<space>

"----------buftabs----------
let g:buftabs_only_basename=1
let g:buftabs_in_statusline=1
let g:buftabs_active_highlight_group="Visual"

"----------netrw----------
let g:netrw_liststyle=3
let g:netrw_list_hide= '^\..*'
noremap <F2> :Explore<CR>
inoremap <F2> <ESC>:Explore<CR>

"----------SimpleCompile----------
noremap <F5> :SimpleCompile<CR>
noremap <F6> :SimpleRun<CR>
inoremap <F5> <ESC>:SimpleCompile<CR>
inoremap <F6> <ESC>:SimpleRun<CR>

"----------po.vim----------
let g:po_translator="lainme <lainme993@gmail.com>"

"----------fuzzyfinder----------
noremap <Leader>so :FufFile<CR>
noremap <Leader>sf :FufTaggedFile<CR>
noremap <Leader>sj :FufJumpList<CR>
noremap <Leader>st :FufTag<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"分类设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------Fortran----------
"折叠
let fortran_fold=1 
let fortran_fold_conditionals=1

"通用
autocmd FileType fortran 
    \setlocal foldmethod=syntax |
    \set efm=%A%f:%l.%c:,%-Z%trror:\ %m,%-Z%tarning:\ %m,%-C%.%#

"设置格式
autocmd BufNewFile,BufReadPre,BufEnter *.f90  
    \unlet! fortran_fixed_source |
    \let fortran_free_source=1 |
autocmd BufNewFile,BufReadPre,BufEnter *.f 
    \unlet! fortran_free_source |
    \let fortran_fixed_source=1 | 
    \setlocal shiftwidth=6 | 
    \setlocal softtabstop=6 |

"----------Python----------
"自动添加文件头
autocmd BufNewFile *.py 
    \0put=\"#!/usr/bin/env python\<nl># -*- coding: UTF-8 -*-\<nl>\"  

"----------Shell----------
"自动添加文件头
autocmd BufNewFile *.sh 
    \0put=\"#!/bin/bash\<nl>\" 

"----------HTML----------
"自动添加文件头
autocmd BufNewFile *.html,*.htm 
    \0put='<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">' |
    \1put='<html xmlns=\"http://www.w3.org/1999/xhtml\" dir=\"ltr\" lang=\"zh-cn\" xml:lang=\"zh-cn\">' |
    \2put='    <head>' |
    \3put='        <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />' |
    \4put='        <title></title>' |
    \5put='    </head>' |
    \6put='    <body>' |
    \7put='    </body>' |
    \8put='</html>' |
    \normal 5G7l

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"其它
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on "开启文件类型支持
syntax on "开启语法高亮
