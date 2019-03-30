function! wilder#pipeline#component#result#make(...) abort
  let l:args = a:0 ? a:1 : {}
  return {ctx, xs -> map(xs, {_, x -> s:result(l:args, ctx, x)})}
endfunction

function! s:result(args, ctx, x) abort
  let l:x = type(a:x) is v:t_string ? {'value': a:x} : a:x

  for l:key in keys(a:args)
    let l:F = a:args[l:key]

    if l:key ==# 'value'
      let l:x.value = l:F(a:ctx, l:x.value)
      continue
    endif

    if has_key(l:x, l:key)
      let l:Prev = l:x[l:key]
    else
      let l:Prev = {ctx, x -> x}
    endif

    let l:x[l:key] = {ctx, x -> l:F(ctx, x, l:Prev)}
  endfor

  return l:x
endfunction
