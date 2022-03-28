if exists("g:loaded_translate")
    finish
endif
let g:loaded_translate = v:true

vmap <leader>t <Cmd>lua require("translate").translateV()<cr>
nmap <leader>t <Cmd>lua require("translate").translateN()<cr>


