if exists("g:loaded_visibuffer")
  finish
endif
let g:loaded_visibuffer = 1

lua require("visibuffer").setup()
