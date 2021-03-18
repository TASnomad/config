set nocompatible

set cursorline
set cursorcolumn

if (has("termguicolors"))
	set termguicolors
endif

let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" " block cursor for normal mode
let &t_SR = "\<esc>[3 q" " underline cursor for replace mode

set encoding=UTF-8
set showmode

filetype off
set foldmethod=syntax
set nofoldenable

set autoread
" Will update an open buffer, if an external program modified the file
au FocusGained,BufEnter * :checktime

set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/.fzf

filetype plugin indent on

set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch
set tags=~/.cache/tags/.tags;,.tags
set listchars=eol:\ ,tab:>\ ,trail:~,precedes:<
set list
syntax enable
set mouse=a
" More natural (and expected) split opening
set splitbelow
set splitright
hi clear SignColumn

call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
	Plugin 'junegunn/fzf.vim'
	Plugin 'neoclide/coc.nvim', { 'branch': 'release' }
	Plugin 'arcticicestudio/nord-vim'
	"Plugin 'morhetz/gruvbox'
	Plugin 'airblade/vim-gitgutter'
	Plugin 'tpope/vim-fugitive'
	Plugin 'scrooloose/nerdtree'
	Plugin 'jistr/vim-nerdtree-tabs'
	Plugin 'vim-airline/vim-airline'
	Plugin 'vim-airline/vim-airline-themes'
	Plugin 'tpope/vim-surround'
	Plugin 'tpope/vim-liquid'
	Plugin 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
call vundle#end()

nnoremap <SPACE> <Nop>
let mapleader=" "

" Better split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nmap <silent> <leader>bk :bd<CR>

let g:airline_powerline_fonts = 1
let g:airline_detect_paste=1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='nord'
let g:airline#extensions#hunks#non_zero_only = 1
let g:indentLine_color_term = 189
let g:indentLine_char = '|'
let g:coc_globals_extensions = [ 'coc-tslint-plugin', 'coc-tsserver', 'coc-json', 'coc-css', 'coc-html', 'coc-yank' ]
let g:nerdtree_tabs_open_on_console_startup = 0
let NERDTreeShowHidden=1

autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

nmap <silent> <leader>op :NERDTreeTabsToggle<CR>

"colorscheme gruvbox
colorscheme nord
set background=dark

" COC completion
inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1] =~# '\s'
endfunction

" ctrl + space triggers autocompletion
inoremap <silent><expr> <c-space> coc#refresh()

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" nmap <silent> gc :Gcommit --no-verify<CR>
" nmap <silent> ga :Gcommit --no-verify --amend<CR>
" nmap <silent> gw :Gwrite<CR><CR>
" nmap <silent> gup :Gpull --all<CR>
" nmap <silent> gps :Gpush<CR>
" nmap <silent> gs :Gstatus<CR>
" nmap <silent> gd :Git d<CR>
" nmap <silent> gds :Git ds<CR>

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
        if (index(['vim', 'help'], &filetype) >= 0)
                execute 'h '.expand('<cword>')
        else
                call CocAction('doHover')
        endif
endfunction

" Hightlight symbol on the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" \rn rename the current word
nmap <leader>rn <Plug>(coc-rename)

" \f for format
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

"imap <c-x><c-w> <plug>(fzf-complete-word)
"imap <c-x><c-f> <plug>(fzf-complete-path)
"imap <c-x><c-j> <plug>(fzf-complete-file-ag)
"imap <c-x><c-l> <plug>(fzf-complete-line)

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

function s:tabName(n)
        let blist = tabpagebuflist(a:n)
        let winnr =  tabpagewinnr(a:n)
        return fnamemodify(bufname(blist[winnr - 1]), ':t')
endfunction

function! s:jumpToTab(line)
        let pair = split(a:line, ' ')
        let cmd = pair[0].'gt'
        execute 'normal' cmd
endfunction

" Better navigation: the current line is always at middle of the screen
nnoremap k kzz
nnoremap j jzz
nnoremap p pzz
nnoremap P Pzz
nnoremap G Gzz
nnoremap x xzz
nnoremap <PageUp> <PageUp>zz
nnoremap <PageDown> <PageDown>zz

nnoremap <C-c> :Commits<CR>
nnoremap <C-f> :BLines<CR>
nnoremap <C-p> :Files<CR>
nnoremap <C-s> :Rg<CR>
nnoremap <C-b> :Buffers<CR>
nnoremap <C-g> :GFiles?<CR>
nnoremap <C-t> :call fzf#run({
\ 'source': reverse(map(range(1, tabpagenr('$')), 'v:val." "." ".<sid>tabName(v:val)')),
\ 'sink': function('<sid>jumpToTab'),
\ 'down': tabpagenr('$') + 2
\ })<CR>

nnoremap <leader>sb :BLines<CR>
nnoremap <leader>pf :Files<CR>
nnoremap <leader>sp :Rg<CR>
nnoremap <leader>g :GFiles?<CR>

let g:fzf_commits_log_options = '--graph --all --topo-order --decorate --color=always'
let g:fzf_layout = { 'down': '~40%' }

function! s:ag_to_qf(line)
  let parts = split(a:line, ':')
  return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
        \ 'text': join(parts[3:], ':')}
endfunction

function! s:ag_handler(lines)
  if len(a:lines) < 2 | return | endif

  let cmd = get({'ctrl-s': 'split',
               \ 'ctrl-v': 'vertical split',
               \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')
  let list = map(a:lines[1:], 's:ag_to_qf(v:val)')

  let first = list[0]
  execute cmd escape(first.filename, ' %#\')
  execute first.lnum
  execute 'normal!' first.col.'|zz'

  if len(list) > 1
    call setqflist(list)
    copen
    wincmd p
  endif
endfunction

command! -nargs=* Ag call fzf#run({
\ 'source':  printf('ag --nogroup --column --color "%s"',
\                   escape(empty(<q-args>) ? '^(?=.)' : <q-args>, '"\')),
\ 'sink*':    function('<sid>ag_handler'),
\ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x --delimiter : --nth 4.. '.
\            '--multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '.
\            '--color hl:4,hl+:12',
\            'left': '~40%',
\ })

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)

" Hide FZF when doing a search
augroup fzf
  autocmd!
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END
