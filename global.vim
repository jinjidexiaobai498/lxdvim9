vim9script

export const use_neovim = has('nvim')
export const use_vim = !use_neovim
export const vim_data_path = use_neovim ? stdpath('data') : '~/.vim'

export const vim_plug_path = use_neovim ? expand('~/.config/nvim/autoload/plug.vim') : expand('~/.vim/autoload/plug.vim')
export var is_installed_plugins = isdirectory(vim_data_path .. '/nerdtree/.git')
export var lsp_status = true

#echom vim_plug_path
