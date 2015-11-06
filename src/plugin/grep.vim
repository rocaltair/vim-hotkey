"
" Author : Roc<rocaltair@gmail.com>
"
" hotkeys:
" 	<F3> start to grep All words under cursor
" 	<C-j> goto next match while matched
" 	<C-k> goto prev match while matched
"
"

let s:is_debug = 0

if !s:is_debug && exists('g:grep_addon_loaded')
	finish
endif
let g:grep_addon_loaded = 1

let s:IsOpen = 0

function! StartGrep()
	if s:IsOpen 
		let s:IsOpen = 0
		cclose
		nunmap <silent> <C-j>
		nunmap <silent> <C-k>
	else
		let s:IsOpen = 1
		grep <cword> | copen 5
		nmap <silent> <C-j> :cn<cr>
		nmap <silent> <C-k> :cp<cr>
	endif
endfunction

if system('which ack > /dev/null && echo true') =~ 'true'
	set grepprg=ack\ -a\ -w
endif
nmap <silent> <F3> :call StartGrep()<cr>

