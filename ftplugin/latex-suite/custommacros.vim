"=============================================================================
" 	     File: custommacros.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" Last Change: Mon Apr 29 04:00 PM 2002 PDT
" 
"  Description: functions for processing custom macros in the
"               latex-suite/macros directory
"=============================================================================

let s:path = expand('<sfile>:p:h')

" SetCustomMacrosMenu: sets up the menu for Macros {{{
function! <SID>SetCustomMacrosMenu()
	let flist = glob(s:path."/macros/*")
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&New :call NewMacro()<CR>'
	exe 'amenu '.g:Tex_MacrosMenuLocation.'&Redraw :call RedrawMacro()<CR>'

	let i = 1
	let k = 1
	while 1
		let fname = Tex_Strntok(flist, "\n", i)
		if fname == ''
			break
		endif
		if fname =~ "CVS"
			let i = i + 1
			continue
		endif
		let fnameshort = fnamemodify(fname, ':p:t:r')
		if fnameshort == ''
			let i = i + 1
			let k = k + 1
			continue
		endif
		exe "amenu ".g:Tex_MacrosMenuLocation."&Delete.&".k.":<tab>".fnameshort." :call <SID>DeleteMacro('".fnameshort."')<CR>"
		exe "amenu ".g:Tex_MacrosMenuLocation."&Edit.&".k.":<tab>".fnameshort."   :call <SID>EditMacro('".fnameshort."')<CR>"
		exe "amenu ".g:Tex_MacrosMenuLocation."&".k.":<tab>".fnameshort." :call <SID>ReadMacro('".fnameshort."')<CR>"
		let i = i + 1
		let k = k + 1
	endwhile
endfunction 

if g:Tex_Menus
	call <SID>SetCustomMacrosMenu()
endif

" }}}
" NewMacro: opens new file in macros directory {{{
function! NewMacro()
	exe "cd ".s:path."/macros"
	new
	set filetype=tex
endfunction

" }}}
" RedrawMacro: refreshes macro menu {{{
function! RedrawMacro()
	aunmenu TeX-Suite.Macros
	call <SID>SetCustomMacrosMenu()
endfunction

" }}}
" DeleteMacro: deletes macro file {{{
function! <SID>DeleteMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for deletion :')
		exe 'cd '.pwd
	endif

	let ch = confirm('Really delete '.filename.' ?', 
		\"Yes\nNo", 2)
	if ch == 1
		call delete(s:path.'/macros/'.filename)
	endif
	call RedrawMacro()
endfunction

" }}}
" EditMacro: edits macro file {{{
function! <SID>EditMacro(...)
	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for insertion:')
		exe 'cd '.pwd
	endif

	exe "split ".s:path."/macros/".filename
	exe "lcd ".s:path."/macros/"
	set filetype=tex
endfunction

" }}}
" ReadMacro: reads in a macro from a macro file.  {{{
"            allowing for placement via placeholders.
function! <SID>ReadMacro(...)

	if a:0 > 0
		let filename = a:1
	else
		let pwd = getcwd()
		exe 'cd '.s:path.'/macros'
		let filename = Tex_ChooseFile('Choose a macro file for insertion:')
		exe 'cd '.pwd
	endif

	let _a = @a
	let fname = glob(s:path."/macros/".filename)
	silent! exec "normal! o�!�Temp Line�!�\<ESC>k"
	silent! exec "read ".fname
	silent! exec "normal! V/^�!�Temp Line�!�$/-1\<CR>\"ax"
	call Tex_CleanSearchHistory()
	
	silent! exec "normal! i\<C-r>='�!�Start here�!�'.IMAP_PutTextWithMovement(@a)\<CR>"
	let pos = line('.').'| normal! '.virtcol('.').'|'

	call search('^�!�Temp Line�!�$')
	. d _
	call search('�!�Start here�!�')
	silent! normal! v15l"_x

	call TeX_pack_all()

	silent! exe pos
	if col('.') < strlen(getline('.'))
		silent! normal! l
	endif
	silent! startinsert
endfunction

" }}}
" commands for macros {{{
com! -nargs=? TexMacro          :call <SID>ReadMacro(<f-args>)
com! -nargs=0 TexMacroNew       :call <SID>NewMacro()
com! -nargs=? TexMacroEdit      :call <SID>EditMacro(<f-args>)
com! -nargs=? TexMacroDelete    :call <SID>DeleteMacro(<f-args>)

" }}}

" vim:fdm=marker:ts=4:sw=4:noet
