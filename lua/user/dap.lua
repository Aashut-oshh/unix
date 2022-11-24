-- DAP or debug adapter protocol is for debugging code just like LSP for linting and autocomplete, popup etc.
local status_ok, dap = pcall(require,'dap')
if not status_ok then
	vim.notify("dap not found. skipping.")
	return
end

----------- C/C++/Rust -------------
-- Adapter
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}

-- Configurations
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}

-- If you want to use this for Rust and C, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- Keymappings
local opts = { noremap=true, silent=true } --, buffer=vim.fn.expand('%') }
-- vim.keymap.set('n', '<F5>', dap.continue(), opts) -- The vim function not working and so is the direct call to the dap function. It should be string I suppose.
-- vim.api.nvim_set_keymap('n', '<leader>b', dap.toggle_breakpoint(), opts)
vim.api.nvim_set_keymap('n', '<F5>', '<Cmd>lua require\'dap\'.continue()<CR>', opts)
vim.api.nvim_set_keymap('n', '<F10>', '<Cmd>lua require\'dap\'.step_over()<CR>', opts)
vim.api.nvim_set_keymap('n', '<F11>', '<Cmd>lua require\'dap\'.step_into()<CR>', opts)
vim.api.nvim_set_keymap('n', '<F12>', '<Cmd>lua require\'dap\'.step_out()<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>b', '<Cmd>lua require\'dap\'.toggle_breakpoint()<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>B', '<Cmd>lua require\'dap\'.set_breakpoint(vim.fn.input(\'Breakpoint condition: \'))<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>lp', '<Cmd>lua require\'dap\'.set_breakpoint(nil, nil, vim.fn.input(\'Log point message: \'))<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>dr', '<Cmd>lua require\'dap\'.repl.open()<CR>', opts)
vim.api.nvim_set_keymap('n', '<Leader>dl', '<Cmd>lua require\'dap\'.run_last()<CR>', opts)
