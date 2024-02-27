# vimrc written in vim9script

well config and easy to improve , all config  file add in a project and split into modules and face to object coding

You can use it to write c, cpp, rust, python and so on

## keymap table

    1.  ,c      select colorsheme
    2.  ,f      fluzy find files by name in your git project
    3.  ,l      find word in your git project
    4.  ,p      select history project
    5.  ,r      recentfiles and fluzy search in recentfiles
    6.  ,g      lazygit keymap if you has lazygit installed in you path
    7.  ,w      workspace file dir browser
    8.  ,e ,d   netrw toggle
    9.  ,n      nerdtree find toggle
    10. ,s      symbol talbe toggle
    10. <C-n>   nerdtree toggle
    11. <C-p>   keymap fluzy search

## Require

1. vim 9.0 ++
2. only tested on archlinux and windows10 now

##  install
```bash
git clone https://gitee.com/thousands-of-miles/lxdvimrc ~/.config/vim/lxdvimrc --depth 1
```

add this line in your vimrc
```vim
let g:lxdvim_extend_plug = 0 " change to '1' to enable coc-nvim to use clangd , rust-analyzer and so on
source ~/.config/vim/lxdvimrc/init.vim
```
