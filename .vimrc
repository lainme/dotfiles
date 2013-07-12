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
set undodir=$HOME/.vim-undo "设置undodir
set directory=/tmp "设置swp文件目录
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

"GVIM的一些设置
if has("gui_running")
    set guioptions=a  "去掉菜单等，自动复制选择的区域
    set guicursor=a:blinkwait600-blinkoff600-blinkon600 "光标闪烁频率
    set guifont=Monospace\ 11
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

"quickfix设置
autocmd QuickFixCmdPost * :cw
nnoremap <Leader>fn :cn<CR>
nnoremap <Leader>fp :cp<CR>
nnoremap <Leader>fo :copen<CR>
nnoremap <Leader>fc :ccl<CR>

"缓冲区移动键映射
nnoremap <M-h> :bprev!<CR>
nnoremap <M-l> :bnext!<CR>
inoremap <M-h> <ESC>:bprev!<CR>
inoremap <M-l> <ESC>:bnext!<CR>

"TAG跳转
nnoremap <c-]> g<c-]>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"工具
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"在当前文件路径打开终端
nnoremap <F7> :call OpenTerminal()<CR>
inoremap <F7> <ESC>:call OpenTerminal()<CR>

function! OpenTerminal()
    let s:terminal = "xterm"
    silent exec '!'.s:terminal.' -e bash -c "cd \"'.expand("%:p:h").'\";bash"'
    redraw!
endfunction

"附加模式行
nnoremap <Leader>ml :call AppendModeline()<CR>

function! AppendModeline()
    let s:modeline = substitute(substitute(substitute(&commentstring,"\\s\*%s\\s\*","%s",""),"%s",printf(" vim: set ft=%s ff=%s tw=%s:", &filetype,&fileformat,&textwidth)," "),"^\\s\\+","","")
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
Bundle 'The-NERD-Commenter'
Bundle 'buftabs'
Bundle 'po.vim--Jelenak'
Bundle 'SudoEdit.vim'
Bundle 'fcitx.vim'
Bundle 'LaTeX-Box'
Bundle 'notes.vim'
Bundle 'DirDiff.vim'
Bundle 'vim-flake8'
Bundle 'lainme/simplecompile'
Bundle 'lainme/simpleProj'

"----------taglist----------
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Left_Window=1
let Tlist_Show_One_File=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_Enable_Fold_Column=0
let Tlist_Auto_Updata=1
let Tlist_Compact_Format = 1
let tlist_tex_settings   = 'latex;s:sections;g:graphics;l:labels'
nnoremap <F3> :TlistUpdate<CR>:TlistToggle<CR>
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
nnoremap <F2> :Explore<CR>
inoremap <F2> <ESC>:Explore<CR>

"----------SimpleCompile----------
nnoremap <F5> :SimpleCompile<CR>
nnoremap <F6> :SimpleRun<CR>
inoremap <F5> <ESC>:SimpleCompile<CR>
inoremap <F6> <ESC>:SimpleRun<CR>

"----------po.vim----------
let g:po_translator="lainme <lainme993@gmail.com>"

"----------notes----------
let g:notes_directory="~/Documents/notes"
let g:notes_suffix=".txt"

"----------simpleProj----------
nnoremap <F8> :ProjGenCtags<CR>
nnoremap <F9> :ProjGrepFile<CR>
inoremap <F8> <ESC>:ProjGenCtags<CR>
inoremap <F9> <ESC>:ProjGrepFile<CR>
nnoremap <Leader>zg :ProjAddSpell<CR>

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
    \setlocal efm=%A%f:%l.%c:,%-Z%trror:\ %m,%-Z%tarning:\ %m,%-C%.%#

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
    \0put=\"#!/bin/sh\<nl>\" 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"其它
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on "开启文件类型支持
syntax on "开启语法高亮
