vim9script

def CheckBackspace(): bool
	var col = col('.') - 1
	return col > 0 || getline('.')[col - 1]  =~# '\s'
enddef

def ShowDocumentation()
	if g:CocAction('hasProvider', 'hover')
		call g:CocActionAsync('doHover')
	else
		call feedkeys('K', 'in')
	endif
enddef

export def Setup()

	# May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
	# utf-8 byte sequence
	set encoding=utf-8
	# Some servers have issues with backup files, see #649
	set nobackup
	set nowritebackup

	# Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
	# delays and poor user experience
	set updatetime=300

	# Always show the signcolumn, otherwise it would shift the text each time
	# diagnostics appear/become resolved
	set signcolumn=yes

	# Use <C-n> for trigger completion with characters ahead and navigate
	# NOTE: There's always complete item selected by default, you may want to enable
	# no select by `"suggest.noselect": true` in your configuration file
	# NOTE: Use command ':verbose imap <C-n>' to make sure tab is not mapped by
	# other plugin before putting this into your config
	inoremap <silent><expr> <C-n>  coc#pum#visible() ? coc#pum#next(1) : <SID>CheckBackspace() ? "\<C-n>" : coc#refresh()
	inoremap <expr><C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"

	# Make <CR> to accept selected completion item or notify coc.nvim to format
	# <C-g>u breaks current undo, please make your own choice
	inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
	inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<TAB>"
	# Use <c-space> to trigger completion
	#inoremap <silent><expr> <c-space> coc#refresh()
	inoremap <silent><expr> <c-space> coc#refresh()
	#inoremap <silent><expr> <c-@> coc#refresh()

	# Use `[g` and `]g` to navigate diagnostics
	# Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
	nmap <silent> [g <Plug>(coc-diagnostic-prev)
	nmap <silent> ]g <Plug>(coc-diagnostic-next)

	# GoTo code navigation
	nmap <silent> gd <Plug>(coc-definition)
	nmap <silent> gy <Plug>(coc-type-definition)
	nmap <silent> gi <Plug>(coc-implementation)
	nmap <silent> gr <Plug>(coc-references)

	# Use K to show documentation in preview window
	nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

	# Highlight the symbol and its references when holding the cursor
	autocmd CursorHold * silent call g:CocActionAsync('highlight')

	# Symbol renaming
	nmap <leader>lr <Plug>(coc-rename)

	# Formatting selected code
	#xmap <leader>F  <Plug>(coc-format-selected)
	#nmap <leader>F  <Plug>(coc-format-selected)
	nmap <leader>F <Plug>(coc-format)

	augroup CocAutocmd
		autocmd!
		# Setup formatexpr specified filetype(s)
		autocmd FileType typescript,json setl formatexpr=g:CocAction('formatSelected')
		# Update signature help on jump placeholder
		autocmd User CocJumpPlaceholder call g:CocActionAsync('showSignatureHelp')
	augroup end

	# Applying code actions to the selected code block
	# Example: `<leader>aap` for current paragraph
	xmap <leader>a  <Plug>(coc-codeaction-selected)
	nmap <leader>a  <Plug>(coc-codeaction-selected)

	# Remap keys for applying code actions at the cursor position
	nmap <leader>ac  <Plug>(coc-codeaction-cursor)
	# Remap keys for apply code actions affect whole buffer
	nmap <leader>as  <Plug>(coc-codeaction-source)
	# Apply the most preferred quickfix action to fix diagnostic on the current line
	nmap <leader>qf  <Plug>(coc-fix-current)

	# Remap keys for applying refactor code actions
	nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
	xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
	nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

	# Run the Code Lens action on the current line
	nmap <leader>cl  <Plug>(coc-codelens-action)

	# Map function and class text objects
	# NOTE: Requires 'textDocument.documentSymbol' support from the language server
	xmap if <Plug>(coc-funcobj-i)
	omap if <Plug>(coc-funcobj-i)
	xmap af <Plug>(coc-funcobj-a)
	omap af <Plug>(coc-funcobj-a)
	xmap ic <Plug>(coc-classobj-i)
	omap ic <Plug>(coc-classobj-i)
	xmap ac <Plug>(coc-classobj-a)
	omap ac <Plug>(coc-classobj-a)

	# Add `:Format` command to format current buffer
	# Add `:Fold` command to fold current buffer
	# Add `:OR` command for organize imports of the current buffer
	command! -nargs=0 Format :call g:CocActionAsync('format')
	command! -nargs=? Fold :call     g:CocAction('fold', <f-args>)
	command! -nargs=0 OR   :call     g:CocActionAsync('runCommand', 'editor.action.organizeImport')

	# Add (Neo)Vim's native statusline support
	# NOTE: Please see `:h coc-status` for integrations with external plugins that
	# provide custom statusline: lightline.vim, vim-airline
	set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

	# Mappings for CoCList
	# Show all diagnostics
	nnoremap <silent><nowait> <space>la  :<C-u>CocList diagnostics<cr>
	# Manage extensions
	nnoremap <silent><nowait> <space>le  :<C-u>CocList extensions<cr>
	# Show commands
	nnoremap <silent><nowait> <space>lc  :<C-u>CocList commands<cr>
	# Find symbol of current document
	nnoremap <silent><nowait> <space>lo  :<C-u>CocList outline<cr>
	# Search workspace symbols
	nnoremap <silent><nowait> <space>ls  :<C-u>CocList -I symbols<cr>
	# Do default action for next item
	nnoremap <silent><nowait> <space>lj  :<C-u>CocNext<CR>
	# Do default action for previous item
	nnoremap <silent><nowait> <space>lk  :<C-u>CocPrev<CR>
	# Resume latest coc list
	nnoremap <silent><nowait> <space>lp  :<C-u>CocListResume<CR>

	# Use CTRL-x for selections ranges
	# Requires 'textDocument/selectionRange' support of language server
	nmap <silent> <C-x> <Plug>(coc-range-select)
	xmap <silent> <C-x> <Plug>(coc-range-select)


	# Remap <C-f> and <C-b> to scroll float windows/popups
	if has('nvim-0.4.0') || has('patch-8.2.0750')
		nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
		nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
		inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
		inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
		vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
		vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
	endif
enddef
