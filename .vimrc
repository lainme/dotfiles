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
set sessionoptions=buffers,sesdir,folds,tabpages,winsize,options "session设置
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk
set runtimepath+=$HOME/.vim "设置runtimepath
set path=.,, "设置path
set spellsuggest=best,10 "最佳的10个拼写建议
set spellfile=$HOME/.vim/spell/en.utf-8.add "设置拼写检查文件
set undodir=$HOME/.vim-undo "设置undodir
set directory=$HOME/.tmp "设置swp文件目录
set formatoptions+=m "中文断行
set t_ut= "禁用背景色刷新
let mapleader="," "设置leader键
colorscheme lucius "配色主题

if ! has("gui_running")
    "修复ALT键
    for i in range(97,122)
        let c=nr2char(i)
        exec "set <M-".c.">=\<Esc>".c
    endfor
    set ttimeoutlen=50

    "避免终端退出时乱码(似乎反而会引起问题)
    "set t_fs=(B
    "set t_IE=(B
else
    set guioptions=a  "去掉菜单等，自动复制选择的区域
    set guicursor=a:blinkwait600-blinkoff600-blinkon600 "光标闪烁频率
    set guifont=Inconsolata\ 12
endif

"状态栏设置
set laststatus=2
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P

"备份设置
set backup
set backupdir=$HOME/.tmp

"用四个空格代替<tab>
set expandtab smarttab
set shiftwidth=4
set softtabstop=4

"重置光标到上次会话的位置
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g`\"" |
    \ endif

"删除多余的空格
"autocmd BufWritePre * :%s/\s\+$//e
nnoremap <Leader>ss :%s/\s\+$//e<CR>

"quickfix设置
autocmd QuickFixCmdPost * :cw
nnoremap <Leader>fn :cn<CR>
nnoremap <Leader>fp :cp<CR>
nnoremap <Leader>fo :copen<CR>
nnoremap <Leader>fc :ccl<CR>

"折叠的键映射
nnoremap <M-z> za
nnoremap <M-x> zA
inoremap <M-z> <C-o>za
inoremap <M-x> <C-o>zA

"缓冲区移动键映射
nnoremap <M-left> :bprev!<CR>
nnoremap <M-right> :bnext!<CR>
inoremap <M-left> <ESC>:bprev!<CR>
inoremap <M-right> <ESC>:bnext!<CR>

"TAG跳转
nnoremap <c-]> g<c-]>

"ESC
inoremap jj <ESC>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"工具
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"编译当前文件
nnoremap <F4> :silent exec "w\|make\|redraw!"<CR>
inoremap <F4> <ESC>:silent exec "w\|make\|redraw!"<CR>

"在当前文件路径打开终端
nnoremap <F5> :silent exec "!cd ".expand("%:p:h").";xterm&" \|redraw!<CR>
inoremap <F5> <ESC>:silent exec "!cd ".expand("%:p:h").";xterm&" \|redraw!<CR>

"附加模式行
nnoremap <Leader>ml :call AppendModeline()<CR>
function! AppendModeline()
    let s:setting = printf(" vim: set ft=%s ff=%s tw=%s:", &filetype, &fileformat, &textwidth)
    let s:modeline = substitute(&commentstring, "%s", s:setting, "")
    call append(line("$"),"")
    call append(line("$"),s:modeline)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"插件设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------Vundle----------
set rtp+=$HOME/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'taglist.vim'
Bundle 'The-NERD-Commenter'
Bundle 'buftabs'
Bundle 'LaTeX-Box'

"----------taglist----------
let Tlist_Enable_Fold_Column=0
let Tlist_Exit_OnlyWindow=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_Show_One_File=1
let tlist_tex_settings='latex;s:sections;g:graphics;l:labels'
nnoremap <F2> :TlistUpdate<CR>:TlistToggle<CR>
inoremap <F2> <ESC>:TlistUpdate<CR>:TlistToggle<CR>

"----------NERD_commenter----------
nmap <F3> ,c<space>
vmap <F3> ,c<space>
imap <F3> <C-o>,c<space>

"----------buftabs----------
let g:buftabs_only_basename=1
let g:buftabs_in_statusline=1
let g:buftabs_active_highlight_group="Visual"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"分类设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------Fortran----------
let fortran_fold=1
let fortran_fold_conditionals=1
let fortran_free_source=1

autocmd FileType fortran
    \ setlocal foldmethod=syntax |
    \ setlocal makeprg=gfortran\ -ffree-line-length-0\ -o\ %<\ %\ -J\ $HOME/.tmp |
    \ setlocal efm=%E%f:%l.%c:,%E%f:%l:,%C,%C%p%*[0123456789^],%ZError:\ %m,%C%.%#

"----------Python----------
autocmd BufNewFile *.py
    \ 0put=\"#!/usr/bin/env python\<nl># -*- coding: UTF-8 -*-\<nl>\"

"----------Latex----------
autocmd FileType tex
    \ setlocal makeprg=rubber\ --inplace\ -m\ xelatex\ --shell-escape\ -q\ % |
    \ nnoremap <buffer> <F6> :LatexView<CR> |
    \ inoremap <buffer> <F6> <ESC>:LatexView<CR>

"----------Rmarkdown----------
autocmd BufRead,BufNewFile *.Rmd set filetype=txt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"其它
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on "开启文件类型支持
syntax on "开启语法高亮
