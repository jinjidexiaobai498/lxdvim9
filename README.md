# like Spacevim but write in vim9script, well config and easy to extend in coding 

well config and easy to improve , all config  file add in a project and split into modules and face to object coding

## Require

1. only vim 9.0 ++
2. only tested on archlinux and windows10 now

##  install
```bash
git clone https://github.com/jinjidexiaobai498/lxdvim9 $HOME/.config/vim/lxdvim9 --depth 1
```

add this line in your vimrc
```vim
let g:lxdvim_extend_plug = 0 " change to '1' to enable coc-nvim to use clangd , rust-analyzer and so on
source ~/.config/vim/lxdvim9/init.vim
```
## used plugins list

### basic vim config which do not include languiage server  feature
- fzf
- FixedTaskList
- vim-surround
- taglist
- vim-which-key
- nerdcommenter
- nerdtree

and some built-in plugins which are written by myself

- colors-selected
- terminal-help
- project-session

### extend  plugins ( mostly about languiage server feautures and you can add plugin which you like)

- coc-nvim

> open by add *g:lxdvim_extend_plug = true* in your vimrc 

default do not use extend plugins

## default config options

```vim
g:lxdvim_extend_plug = false
```

