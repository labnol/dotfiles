" Settings for both terminal vim and MacVim.

" Color scheme that ships with vim: bright text on a dark background.
colorscheme pablo

" Show line numbers down the left side.
set nu

" Highlight the line the cursor is on, so it's easy to find.
set cursorline

" Wrap long lines onto the next screen row instead of scrolling sideways.
" This only changes how lines are shown; no line breaks are added to the file.
set wrap

" When wrapping, break at a space or punctuation rather than mid-word.
set linebreak

" Use the macOS clipboard for yank and paste, so y copies text you can paste
" into other apps, and p pastes what you copied elsewhere.
set clipboard=unnamed

" Skip the intro screen (version and help text) when vim starts with no file.
set shortmess+=I
