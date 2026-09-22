 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131313',
    base01 = '#1f1f1f',
    base02 = '#2a2a2a',
    base03 = '#919191',
    base04 = '#c6c6c6',
    base05 = '#e2e2e2',
    base06 = '#e2e2e2',
    base07 = '#e2e2e2',
    base08 = '#ffb4ab',
    base09 = '#dac58d',
    base0A = '#e7bdb3',
    base0B = '#ffb4a1',
    base0C = '#dac58d',
    base0D = '#ffb4a1',
    base0E = '#e7bdb3',
    base0F = '#ffdbd2',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e2e2e2',          bg = '#131313' })
  hi('TelescopeBorder',         { fg = '#919191',             bg = '#131313' })
  hi('TelescopePromptNormal',   { fg = '#e2e2e2',          bg = '#131313' })
  hi('TelescopePromptBorder',   { fg = '#919191',             bg = '#131313' })
  hi('TelescopePromptPrefix',   { fg = '#ffb4a1',             bg = '#131313' })
  hi('TelescopePromptCounter',  { fg = '#c6c6c6',  bg = '#131313' })
  hi('TelescopePromptTitle',    { fg = '#131313',             bg = '#ffb4a1' })
  hi('TelescopePreviewTitle',   { fg = '#131313',             bg = '#e7bdb3' })
  hi('TelescopeResultsTitle',   { fg = '#131313',             bg = '#dac58d' })
  hi('TelescopeSelection',      { fg = '#e2e2e2',          bg = '#2a2a2a' })
  hi('TelescopeSelectionCaret', { fg = '#ffb4a1',             bg = '#2a2a2a' })
  hi('TelescopeMatching',       { fg = '#ffb4a1',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e2e2e2',          bg = '#131313' })
  hi('MiniPickBorder',         { fg = '#919191',             bg = '#131313' })
  hi('MiniPickPrompt',   { fg = '#e2e2e2',          bg = '#131313' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb4a1',             bg = '#131313' })
  hi('MiniPickBorderText',    { fg = '#131313',             bg = '#ffb4a1' })
  hi('MiniPickMatchCurrent',      { fg = '#e2e2e2',          bg = '#2a2a2a' })
  hi('MiniPickPromptCaret', { fg = '#ffb4a1',             bg = '#2a2a2a' })
  hi('MiniPickMatchRanges',       { fg = '#ffb4a1',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
