-- Disable arrow keys for navigation to encourage hjkl usage
vim.cmd('map <Up> <Nop>')
vim.cmd('map <Down> <Nop>')
vim.cmd('map <Left> <Nop>')
vim.cmd('map <Right> <Nop>')

-- Also disable in insert mode
vim.cmd('imap <Up> <Nop>')
vim.cmd('imap <Down> <Nop>')
vim.cmd('imap <Left> <Nop>')
vim.cmd('imap <Right> <Nop>')