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
execute "normal! o\n\n# Change config_qa flow to include load_dataset step\n"
redraw
execute "normal! oflows:\n"
redraw
sleep 1000m
execute "normal! i    config_qa:\n"
redraw
sleep 1000m
execute "normal! i        steps:\n"
redraw
sleep 1000m
execute "normal! i            3:\n"
redraw
sleep 1000m
execute "normal! i                task: "
redraw
sleep 1000m
execute "normal i load_dataset\n"
redraw
sleep 5000m
redraw
execute "normal ZZ"
