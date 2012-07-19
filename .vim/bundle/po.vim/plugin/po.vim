" VIM filetype plugin
" Language:	PO-files (message catalogs for gettext)
" Maintainer:	Michael Piefel <piefel@informatik.hu-berlin.de>
" Last Change:	30 May 2001
" Licence:	Public Domain

" Do this for every buffer
nnoremap <buffer> <CR>     :call <SID>OpenFile()<CR>

if exists("g:did_po_ftplugin")
    finish
endif

" Don't load another plugin (this is global)
let g:did_po_ftplugin = 1

" This function removes the quotes in a translation entry.
" It also joins lines which are split because the PO file is supposed to only
" have a tw of 80 (Emacs?), but where the contents of the line is shorter than
" 80 characters.
function s:Unstringify()
    let reportsave=&report
    set report=65535
    if search('^msgstr ""$', "b") > 0
	let anfang = line(".")+1
	if search('^$') > 0
	    let ende = line(".")
	    execute ende . "," . ende . 's/^$/###---end of entry---###/'
	    execute anfang . "," . ende . 's/^"//'
	    execute anfang . "," . ende . 's/\\n"$//e'
	    execute anfang . "," . ende . 's/ "\n/ /e'
	endif
    endif
    let &report=reportsave
endfunction

" This adds quotes around an entry.
" It also adds the \n characters. It doesn't split lines which are too long,
" because there's really no need for that.
function s:Stringify()
    let reportsave=&report
    set report=65535
    if search('^msgstr ""$', "b") > 0
	let anfang = line(".")+1
	if search('^###---end of entry---###$') > 0
	    let ende = line(".")-1
	    execute (ende+1) . "," . (ende+1) . 's/###---end of entry---###//'
	    execute anfang . "," . ende . 's/^\(.*\)$/"\1\\n"/'
	endif
    endif
    let &report=reportsave
endfunction 

" This opens the file under the cursor
" In PO files, there are comments like src/hallo.c:45 to point to the spot the
" string is defined. This routine extracts the name and the line number,
" splits the window and positions the cursor.
function s:OpenFile()
    let currline=line(".")
    if search(" ", 'b') != currline
	return
    else
	let anfang=col(".")
    endif

    if search(":") != currline
	return
    else
	let mitte=col(".")
    endif

    if search(" ") != currline
	let ende=strlen(getline(currline))+1
    else
	let ende=col(".")
    end
    
    let datei=strpart(getline(currline), anfang, mitte-anfang-1)
    let line=strpart(getline(currline), mitte, ende-mitte-1)

    if matchend(getcwd(), '/po$') == strlen(getcwd())
	let dirpre="../"
    else
	let dirpre=""
    endif
    execute "silent sp +" . line . " " . dirpre . datei
endfunction

" Send translated entry to the Translation Project
" The file is attached, subject is package-version.team.po
function s:SendMail()
    write
    call system('mail -s "TP-Robot ' . s:Canon_name() .
	\ '" translation@iro.umontreal.ca < ' . bufname('%'))
endfunction

function s:Canon_name()
    execute 1
    if search('^"Project-Id-Version:') == 0
	echohl WarningMsg | echo "\rNo Project-Id-Version" | echohl None
    endif
    let piv=getline(line('.'))
    let package=strpart(piv, match(piv, ': ')+2)
    let package=strpart(package, 0, strridx(package, ' '))
    let pacvers=strpart(piv, strridx(piv, ' ')+1)
    let pacvers=strpart(pacvers, 0, strridx(pacvers, '\n'))
    let team=s:Team_name()
    return input('Name:', package . '-' . pacvers . '.' . team . '.po')
endfunction

function s:Team_name()
    execute 1
    if search('^"Language-Team:') == 0
	echohl WarningMsg | echo "\rUnknown Language Team" | echohl None
    endif
    let longname=strpart(getline(line('.')), 16, match(getline(line('.')), ' <')-16)
    let longname=substitute(longname, '[() ]', '_', 'g')
    
    let NT__Afan__Oromo="om"
    let NT_Abkhazian="ab"
    let NT_Afar="aa"
    let NT_Afrikaans="af"
    let NT_Albanian="sq"
    let NT_Amharic="am"
    let NT_Arabic="ar"
    let NT_Armenian="hy"
    let NT_Assamese="as"
    let NT_Avestan="ae"
    let NT_Aymara="ay"
    let NT_Azerbaijani="az"
    let NT_Bashkir="ba"
    let NT_Basque="eu"
    let NT_Belarusian="be"
    let NT_Bengali="bn"
    let NT_Bihari="bh"
    let NT_Bislama="bi"
    let NT_Bosnian="bs"
    let NT_Brazilian_Portuguese="pt_BR"
    let NT_Breton="br"
    let NT_Bulgarian="bg"
    let NT_Burmese="my"
    let NT_Catalan="ca"
    let NT_Chamorro="ch"
    let NT_Chechen="ce"
    let NT_Chinese="zh"
    let NT_Church_Slavic="cu"
    let NT_Chuvash="cv"
    let NT_Cornish="kw"
    let NT_Corsican="co"
    let NT_Croatian="hr"
    let NT_Czech="cs"
    let NT_Danish="da"
    let NT_Dutch="nl"
    let NT_Dzongkha="dz"
    let NT_English="en"
    let NT_Esperanto="eo"
    let NT_Estonian="et"
    let NT_Faroese="fo"
    let NT_Fijian="fj"
    let NT_Finnish="fi"
    let NT_French="fr"
    let NT_Frisian="fy"
    let NT_Galician="gl"
    let NT_Georgian="ka"
    let NT_German="de"
    let NT_Greek="el"
    let NT_Guarani="gn"
    let NT_Gujarati="gu"
    let NT_Hausa="ha"
    let NT_Hebrew="he"
    let NT_Herero="hz"
    let NT_Hindi="hi"
    let NT_Hiri_Motu="ho"
    let NT_Hungarian="hu"
    let NT_Icelandic="is"
    let NT_Indonesian="id"
    let NT_Interlingua="ia"
    let NT_Interlingue="ie"
    let NT_Inuktitut="iu"
    let NT_Inupiak="ik"
    let NT_Irish="ga"
    let NT_Italian="it"
    let NT_Japanese="ja"
    let NT_Javanese="jw"
    let NT_Kalaallisut="kl"
    let NT_Kannada="kn"
    let NT_Kashmiri="ks"
    let NT_Kazakh="kk"
    let NT_Khmer="km"
    let NT_Kikuyu="ki"
    let NT_Kinyarwanda="rw"
    let NT_Kirghiz="ky"
    let NT_Kirundi="rn"
    let NT_Komi="kv"
    let NT_Konkani="kok"
    let NT_Korean="ko"
    let NT_Kuanyama="kj"
    let NT_Kurdish="ku"
    let NT_Laotian="lo"
    let NT_Latin="la"
    let NT_Latvian="lv"
    let NT_Letzeburgesch="lb"
    let NT_Lingala="ln"
    let NT_Lithuanian="lt"
    let NT_Macedonian="mk"
    let NT_Malagasy="mg"
    let NT_Malay="ms"
    let NT_Malayalam="ml"
    let NT_Maltese="mt"
    let NT_Manipuri="mni"
    let NT_Manx="gv"
    let NT_Maori="mi"
    let NT_Marathi="mr"
    let NT_Marshall="mh"
    let NT_Moldavian="mo"
    let NT_Mongolian="mn"
    let NT_Nauru="na"
    let NT_Navajo="nv"
    let NT_Ndonga="ng"
    let NT_Nepali="ne"
    let NT_North_Ndebele="nd"
    let NT_Northern_Sami="se"
    let NT_Norwegian_Bokmal="nb"
    let NT_Norwegian_Nynorsk="nn"
    let NT_Norwegian="no"
    let NT_Nyanja="ny"
    let NT_Occitan="oc"
    let NT_Oriya="or"
    let NT_Ossetian="os"
    let NT_Pali="pi"
    let NT_Pashto="ps"
    let NT_Persian="fa"
    let NT_Polish="pl"
    let NT_Portuguese="pt"
    let NT_Punjabi="pa"
    let NT_Quechua="qu"
    let NT_Rhaeto-Roman="rm"
    let NT_Romanian="ro"
    let NT_Russian="ru"
    let NT_Samoan="sm"
    let NT_Sango="sg"
    let NT_Sanskrit="sa"
    let NT_Sardinian="sc"
    let NT_Scots="gd"
    let NT_Serbian="sr"
    let NT_Sesotho="st"
    let NT_Setswana="tn"
    let NT_Shona="sn"
    let NT_Sindhi="sd"
    let NT_Sinhalese="si"
    let NT_Siswati="ss"
    let NT_Slovak="sk"
    let NT_Slovenian="sl"
    let NT_Somali="so"
    let NT_Sorbian="wen"
    let NT_South_Ndebele="nr"
    let NT_Spanish="es"
    let NT_Sundanese="su"
    let NT_Swahili="sw"
    let NT_Swedish="sv"
    let NT_Tagalog="tl"
    let NT_Tahitian="ty"
    let NT_Tajik="tg"
    let NT_Tamil="ta"
    let NT_Tatar="tt"
    let NT_Telugu="te"
    let NT_Thai="th"
    let NT_Tibetan="bo"
    let NT_Tigrinya="ti"
    let NT_Tonga="to"
    let NT_Tsonga="ts"
    let NT_Turkish="tr"
    let NT_Turkmen="tk"
    let NT_Twi="tw"
    let NT_Uighur="ug"
    let NT_Ukrainian="uk"
    let NT_Urdu="ur"
    let NT_Uzbek="uz"
    let NT_Vietnamese="vi"
    let NT_Volapuk="vo"
    let NT_Welsh="cy"
    let NT_Wolof="wo"
    let NT_Xhosa="xh"
    let NT_Yiddish="yi"
    let NT_Yoruba="yo"
    let NT_Zhuang="za"
    let NT_Zulu="zu"
    if exists("NT_" . longname)
	return NT_{longname}
    else
	echohl WarningMsg | echo "\rUnknown Language Team" | echohl None
    endif
endfunction

" Adjust spelling to according to iX rules
" Many more corrections are possible, but are optional.
" Many are still needed, but are hard to do automatically.
function s:NewGerman()
    execute '%s/\([Gg]\)raphi\([^c]\)/\1rafi\2/ge'
	" Graphik -> Grafik
    execute '%s/\<\([mMnN]u\)ﬂ\>/\1ss/ge'
	" Muﬂ -> Muss, Nuﬂ -> Nuss 
    execute '%s/\([pPnNdD]a\)ﬂ/\1ss/ge'
	" Paﬂ -> Pass, Naﬂ -> Nass, daﬂ -> dass
    execute '%s/\([mM]\)iﬂ/\1iss/ge'
	" Miﬂ... -> Miss...
    execute "%s/giﬂ\\([t']?\\)/giss\\1/ge"
	" (ver)giﬂ[t'] -> giss[t']
    execute '%s/\([lLfFpP]\)\([‰a]\)ﬂt\\>/\1\2sst/ge' 
	" laﬂt -> lasst, 
	" l‰ﬂt -> l‰sst, 
	" faﬂt -> fasst,
    execute '%s/\([Pp]roze\)ﬂ/\1ss/ge'
	" Prozeﬂ -> Prozess...
    execute '%s/\\<\([aA]dre\)ﬂ/\1ss/ge'
	" Adreﬂ... -> Adress...
    execute '%s/\([mM]\)enue?\\>/\1en¸/ge'
	" Menu -> Men¸
    execute '%s/\([pP]\)otenti/\1otenzi/ge'
	" Potenti... -> Potenzi...
    execute '%s/\\<\([mM][u¸]\)ﬂ\([^e]\)/\1ss\2/ge'
	" "m¸ﬂte" aber nicht "Muﬂe"!
    execute '%s/\([sS]chlu\)ﬂ/\1ss/ge'
	" ...schluﬂ -> schluss
    execute '%s/\([sS]\)ogenannt\(.*\)\\>/\1o genannt\2/ge'
	" sogenannt -> so genannt
    execute '%s/\([aA]\)usser/\1ﬂer/ge'
	" ausser -> auﬂer
    execute '%s/\([hH]\)eiss/\1eiﬂ/ge'
	"  heiss  -> heiﬂ
    execute '%s/\([hH]\)ier zu Lande/\1ierzulande/ge'
	" hier zu Lande -> hierzulande

    " zur Zeit -> zurzeit fehlt, weil es weiterhin "zur Zeit Julius C‰sars" heiﬂt
endfunction

function s:MakeMenu()
    amenu &PO-Editing.&Remove\ quotes		:call <SID>Unstringify()<CR>
    amenu PO-Editing.&Add\ quotes		:call <SID>Stringify()<CR>
    amenu PO-Editing.Unfu&zzy			:?fuzzy? s/, fuzzy//<CR>
    amenu PO-Editing.Jump\ to\ File<TAB>Enter	:call <SID>OpenFile()<CR>
    amenu PO-Editing.-sep-			<nul>
    amenu PO-Editing.&Next\ entry		:call search('\(fuzzy\)\\|\( ""\n\n\)')<CR>
    amenu PO-Editing.Next\ &fuzzy		:call search('fuzzy')<CR>
    amenu PO-Editing.Next\ &untranslated	:call search(' ""\n\n')<CR>
    amenu PO-Editing.-sep-			<nul>
    amenu PO-Editing.Send\ entry\ to\ Translation\ Project   :call <SID>SendMail()<CR>
    amenu PO-Editing.Convert\ old\ to\ new\ German\ spelling :call <SID>NewGerman()<CR>
endfunction

augroup poMenu
au BufEnter * if &filetype == "po" | call <SID>MakeMenu() | setlocal tw=79 et | endif
au BufLeave * if &filetype == "po" | aunmenu PO-Editing | endif
augroup END

