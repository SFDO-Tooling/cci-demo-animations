function AppendLines(newlines)
  syntax on
  sleep 2000m

  let lines = line('$')
  let c = 0
  while c <= lines
    let c += 1
    execute "normal! j"
    redraw
    sleep 100m
  endwhile
  normal! G
  redraw
  execute "normal! o"
  redraw

  for line in a:newlines
    execute "normal! a" . eval(line)
    redraw
    sleep 1000m
  endfor
  sleep 2000m
  execute "normal ZZ"
endfunction
