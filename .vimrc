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
set runtimepath+=$HOME/.vim "设置runtimepath
set spellsuggest=best,10 "最佳的10个拼写建议
set spellfile=$HOME/.vim/spell/en.utf-8.add "设置拼写检查文件
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
if has("unix")
    set backupdir=/tmp
elseif has("win32") || has("win64")
    set backupdir=$TMP 
endif

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
    if has("unix")
        set guifont=Monospace\ 11
    elseif has("win32") || has("win64")
        set guifont=Microsoft_YaHei_Mono:h11
    endif
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
noremap <F7> :call OpenTerminal()<CR>
inoremap <F7> <C-o>:call OpenTerminal()<CR>

function! OpenTerminal()
    if has('win32unix') || has('win32') || has('win64')
        let s:terminal = "start cmd /c mintty.exe"
        let s:curpath = substitute(system('cygpath "'.expand("%:p:h").'"'),"\n$","","e")
    elseif has('unix')
        let s:terminal = "xterm"
        let s:curpath = expand("%:p:h")
    endif
    silent exec '!'.s:terminal.' -e bash -c "cd \"'.s:curpath.'\";bash" &'."\n redraw!"
endfunction


"生成ctags
if ! exists("g:TagCmd")
    let g:TagCmd='ctags -R -o %:p:h/tags %:p:h'
endif

noremap <F8> :exec "silent !".g:TagCmd." &\n redraw!"<CR>
inoremap <F8> <ESC>:exec "w \n silent !".g:TagCmd." &\n redraw!"<CR>

"vimgrep搜索当前工作路径
noremap <F9> :call ProjGrep()<CR>

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

"附加模式行
noremap <Leader>ml :call AppendModeline()<CR>

function! AppendModeline()
    let s:modeline = substitute(substitute(substitute(&commentstring,"\\s\*%s\\s\*","%s",""),"%s",printf(" vim: set ft=%s tw=%s: ", &filetype,&textwidth)," "),"^\\s\\+","","")
    call append(line("$"),s:modeline)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"插件设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------Vundle----------
"required
set rtp+=$HOME/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

"script used
Bundle 'taglist.vim'
Bundle 'TxtBrowser'
Bundle 'The-NERD-Commenter'
Bundle 'buftabs'
Bundle 'po.vim'
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'SudoEdit.vim'
Bundle 'fcitx.vim'
Bundle 'LaTeX-Box-Team/LaTeX-Box'
Bundle 'SuperTab-continued.'
Bundle 'git://github.com/lainme/simplecompile.git'

"----------taglist----------
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Left_Window=1
let Tlist_Show_One_File=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_Enable_Fold_Column=0
let Tlist_Auto_Updata=1
let Tlist_Compact_Format = 1
noremap <F3> :TlistUpdate<CR>:TlistToggle<CR>
inoremap <F3> <ESC>:TlistUpdate<CR>:TlistToggle<CR>

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
if has('win32unix')
    let g:simplecompile_terminal = "mintty.exe"
    let g:simplecompile_pdf = '/cygdrive/c/Program\ Files\ \(x86\)/Adobe/Reader\ 10.0/Reader/AcroRd32.exe'
elseif has('win32') || has('win64')
    let g:simplecompile_terminal = "mintty.exe"
    let g:simplecompile_pdf = 'start cmd /c "C:\Program Files (x86)\Adobe\Reader 10.0\Reader\AcroRd32.exe"'
endif
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

"----------supertab----------
let g:SuperTabRetainCompletionType = 2

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

"----------文本文件----------
"设置类型
noremap <Leader>txt :set filetype=txt \| call AppendModeline()<CR>

"设置HTML输出格式
autocmd FileType txt 
    \let html_number_lines=0 |
    \let html_ignore_folding=1

"----------tex文件----------
autocmd FileType tex 
    \let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"其它
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on "开启文件类型支持
syntax on "开启语法高亮
