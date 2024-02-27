if [ ! -d ~/.config/vim ]; then mkdir ~/.config/vim -p ; fi
git clone https://gitee.com/thousands-of-miles/lxdvimrc ~/.config/vim/lxdvimrc --depth 1
echo "source ~/.config/vim/lxdvimrc/init.vim" > ~/.vimrc
