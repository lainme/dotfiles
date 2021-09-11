cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.Xresources $HOME/.Xresources
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.bashrc $HOME/.bashrc
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.extrarc $HOME/.extrarc
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.ctags $HOME/.ctags
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.screenrc $HOME/.screenrc
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.vimrc $HOME/.vimrc
mkdir -p $HOME/.config
mkdir -p $HOME/.ssh
mkdir -p $HOME/.vim
mkdir -p $HOME/.subversion
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.config/* $HOME/.config/
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.ssh/* $HOME/.ssh/
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.vim/* $HOME/.vim/
cp --no-preserve=all -r /mnt/c/Users/lainme/Dropbox/home/.subversion/* $HOME/.subversion/
chmod 600 $HOME/.ssh/*
