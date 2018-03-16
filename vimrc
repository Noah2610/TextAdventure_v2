nnoremap <leader>rr :!runrb run "~/Projects/Ruby/TextAdventure_v2/TA.rb -e dev" "read -n1" -r "BORDERLESS-<LARGE-SMALL>" -t "termite" -s "bash"<CR><CR>
nnoremap <leader>rp :!runrb run "~/Projects/Ruby/TextAdventure_v2/TA.rb -e production" "read -n1" -r "BORDERLESS-FLOAT" -t "termite" -s "bash"<CR><CR>
nnoremap <leader>rd :!runrb run "~/Projects/Ruby/TextAdventure_v2/TA.rb -e debug" -r "BORDERLESS-<LARGE-SMALL>" -t "termite" -s "bash"<CR><CR>
"nnoremap <leader>rt :!runrb run "~/Projects/Ruby/TextAdventure_v2/TA.rb -e test \| less -R" -r "BORDERLESS-<LARGE-SMALL>" -t "termite" -s "bash"<CR><CR>
nnoremap <leader>rt :!runrb run "~/Projects/Ruby/TextAdventure_v2/bin/run-tests.sh" "read -n1" -r "BORDERLESS-<LARGE-XLARGE>" -t "termite" -s "bash"<CR><CR>
nnoremap <leader>R :!runrb run -r "BORDERLESS-<LARGE-SMALL>" -t "termite" -s "bash" "~/Projects/Ruby/TextAdventure_v2/TA.rb -e " "read -n1"<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
