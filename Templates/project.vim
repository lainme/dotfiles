set noautochdir
exec "cd " . escape(expand("<sfile>:p:h"), ' ')

set spell
set colorcolumn=71
set spellfile=en.utf-8.add
autocmd Filetype tex setlocal makeprg=make

if filereadable("Session.vim")
    source Session.vim
endif
