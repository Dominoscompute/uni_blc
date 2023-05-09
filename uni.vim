function! DeBruijnBlc() abort
  let s:width = 50
  let line = getline('.')
  let line = substitute(line, '\v00|01|1+0', '\r&\r', 'g')
  let line = substitute(line, '\r00\r', '\rλ\r', 'g')
  let line = substitute(line, '\r01\r', '\r@\r', 'g')
  let line = substitute(line, '\v\r(1+0)\r', '\="\r" . (strchars(submatch(1))-1) . "\r"', 'g')
  let line = substitute(line, '\v\r| |\t|\n', '', 'g')
  let height = (strchars(line)/(s:width - 4)) + ((strchars(line)%(s:width - 4)) == 0 ? 0 : 1 ) + 4
  " let height = 10

  let buf = nvim_create_buf(v:false, v:true)

  let ui = nvim_list_uis()[0]

  let opts = {'relative': 'editor',
             \ 'width': s:width,
             \ 'height': height,
             \ 'col': (ui.width/2) - (s:width/2),
             \ 'row': (ui.height/2) - (height/2),
             \ 'anchor': 'NW',
             \ 'style': 'minimal',
             \ }

  let s:vech = '┃' " '|'
  let s:vwch = '┃' " '|'
  let s:hnch = '━' " '-'
  let s:hsch = '━' " '-'
  let s:nwch = '┏' " '+'
  let s:nech = '┓' " '+'
  let s:sech = '┛' " '+'
  let s:swch = '┗' " '+'

  let thborder = s:nwch . repeat(s:hnch, s:width - 2) . s:nech
  let bhborder = s:swch . repeat(s:hsch, s:width - 2) . s:sech
  let eline = s:vwch . repeat(' ', s:width - 2) . s:vech
  let lines = flatten([thborder, eline]) " map(range((height-2)/2+1), 'eline')])

  let split_line = split(line, '.\{' . (s:width - 4) . '}\zs')

  let win = nvim_open_win(buf, 1, opts)

  function s:ln(m)
    return s:vwch . ' ' . (repeat(' ', (s:width - strchars(a:m) - 4)/2)) . a:m . (repeat(' ', strchars(a:m)%2 + (s:width - strchars(a:m) - 4)/2)) . ' ' . s:vwch
  endfunction

  " let offset = 0
  for ln in split_line
    let lines += [s:ln(ln)]
    " let start_col = (s:width - len(ln))/2
    " let end_col = start_col + len(ln)
    " let current_row = height/2-len(split_line)/2 + offset
    " let offset = offset + 1
    " call nvim_buf_set_text(buf, current_row, start_col, current_row, end_col, [ln])
  endfor

  let lines += [eline, bhborder] " [map(range((height-2)/2 - 1), 'eline'), bhborder]

  call nvim_buf_set_lines(buf, 0, -1, v:false, lines)

  let closingKeys = ['<Esc>', '<CR>', '<Leader>']
  for closingKey in closingKeys
    call nvim_buf_set_keymap(buf, 'n', closingKey, ':close<CR>', {'silent': v:true, 'nowait': v:true, 'noremap': v:true})
  endfor
  call nvim_win_set_option(win, 'winhl', 'Normal:Number')
endfunction
