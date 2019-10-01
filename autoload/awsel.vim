
function! awsel#select()
  call s:show_profile_selector()
endfunction


let s:profiles = []
let s:regions = [
 \ 'eu-north-1',
 \ 'ap-south-1',
 \ 'eu-west-3',
 \ 'eu-west-2',
 \ 'eu-west-1',
 \ 'ap-northeast-2',
 \ 'ap-northeast-1',
 \ 'sa-east-1',
 \ 'ca-central-1',
 \ 'ap-southeast-1',
 \ 'ap-southeast-2',
 \ 'eu-central-1',
 \ 'us-east-1',
 \ 'us-east-2',
 \ 'us-west-1',
 \ 'us-west-2',
 \ ]

function! s:sort_with_default(list, default)
  call sort(a:list)
  let l:default = index(a:list, a:default)
  if 0 <= l:default
    call remove(a:list, l:default)
    call insert(a:list, a:default)
  endif
endfunction

function! s:load_credentials()
  let l:lines = readfile(expand('~/.aws/credentials'))
  let s:profiles = []

  for l:line in l:lines
    let l:matched = matchlist(l:line, '\v\[(.+)\]')
    if len(l:matched)
      call add(s:profiles, l:matched[1])
    endif
  endfor

  call s:sort_with_default(s:profiles, $AWS_PROFILE)
endfunction

function! s:show_profile_selector()
  call popup_clear()

  call s:load_credentials()

  call popup_menu(s:profiles, {
    \ 'pos': 'center',
    \ 'drag': 1,
    \ 'callback': function('s:on_profile_selected')
    \ })
endfunction

function! s:on_profile_selected(id, result)
  if a:result == -1
    return
  endif

  let l:selected = s:profiles[a:result - 1]
  let $AWS_PROFILE = l:selected

  call s:show_region_selector()
endfunc

function! s:show_region_selector()
  call popup_clear()

  call s:sort_with_default(s:regions, $AWS_DEFAULT_REGION)

  call popup_menu(s:regions, {
    \ 'pos': 'center',
    \ 'drag': 1,
    \ 'callback': function('s:on_region_selected')
    \ })
endfunction

function! s:on_region_selected(id, result)
  if a:result != -1
    let l:selected = s:regions[a:result - 1]
    let $AWS_DEFAULT_REGION = l:selected
  endif

  call popup_create([
    \   'AWS_PROFILE = ' . $AWS_PROFILE,
    \   'AWS_DEFAULT_REGION = ' . $AWS_DEFAULT_REGION,
    \ ],
    \ {'moved': 'any', 'time': 5000})
endfunction
