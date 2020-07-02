syntax on
sleep 2000m

let c = 0
let lines = line('$')
while c <= lines
  let c += 1
  execute "normal! j"
  redraw
  sleep 100m
endwhile
sleep 2000m
execute "normal ZZ"
