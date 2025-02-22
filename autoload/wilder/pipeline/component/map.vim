function! wilder#pipeline#component#map#make(args) abort
  if len(a:args) == 0
    return {_, x -> []}
  endif

  return {_, x -> {ctx -> s:map(a:args, ctx, x)}}
endfunction

function! s:map(pipelines, ctx, x) abort
  let l:state = {
        \ 'index': 0,
        \ 'pipelines': a:pipelines,
        \ 'original_ctx': copy(a:ctx),
        \ 'original_x': copy(a:x),
        \ 'result': [],
        \ }

  call wilder#pipeline#run(
        \ l:state.pipelines[0],
        \ {ctx, x -> s:on_finish(l:state, ctx, x)},
        \ {ctx, x -> s:on_error(l:state, ctx, x)},
        \ copy(a:ctx),
        \ copy(a:x),
        \ )
endfunction

function! s:on_finish(state, ctx, x) abort
  call add(a:state.result, a:x)

  let a:state.index += 1

  if a:state.index >= len(a:state.pipelines)
    call s:resolve(a:state, a:ctx, a:state.result)
    return
  endif

  call wilder#pipeline#run(
        \ a:state.pipelines[a:state.index],
        \ {ctx, x -> s:on_finish(a:state, ctx, x)},
        \ {ctx, x -> s:on_error(a:state, ctx, x)},
        \ copy(a:state.original_ctx),
        \ copy(a:state.original_x),
        \ )
endfunction

function! s:resolve(state, ctx, x) abort
  let l:ctx = copy(a:ctx)
  let l:ctx.handler_id = a:state.original_ctx.handler_id

  call wilder#resolve(l:ctx, a:x)
endfunction

function! s:on_error(state, ctx, x) abort
  let l:ctx = copy(a:ctx)
  let l:ctx.handler_id = a:state.original_ctx.handler_id

  call wilder#reject(l:ctx, a:x)
endfunction

