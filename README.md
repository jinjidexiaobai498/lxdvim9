# like Spacevim but write in vim9script

##  install
```bash
git clone https://github.com/jinjidexiaobai498/lxdvim9 ~/.config/vim/lxdvim9 --depth 1
```

add this line in your vimrc
```vim
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

default do not use extend plugins 

g:lxdvim\_extend\_plug = false

