-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- vim.cmd([[
--   augroup DiagnosticModeControl
--     autocmd!
--     " Show or hide diagnostics based on the toggle when leaving insert mode or changing text
--     autocmd InsertEnter,InsertLeave,TextChanged,TextChangedI,ModeChanged  * lua if not _G.diagnostics_enabled then vim.diagnostic.hide(nil, 0) end
--   augroup END
-- ]])
local M = {}

-- Namespace for inlay hints
local namespace = vim.api.nvim_create_namespace("inlay_hints")
local inlay_cache = {} -- Cache to store inlay hints by line number

-- Function to clear all inlay hints in the buffer
local function clear_inlay_hints(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  inlay_cache[bufnr] = {} -- Clear the cache for the current buffer
end

-- Helper function to normalize whitespace
local function normalize_whitespace(text)
  -- Replace multiple spaces, tabs, or other whitespace characters with a single space
  return text:gsub("%s+", " ")
end

-- Helper function to extract content within code blocks
local function extract_code_block(hover_lines)
  local inside_code_block = false
  local code_content = {}

  for _, line in ipairs(hover_lines) do
    if line:match("^```") then
      inside_code_block = not inside_code_block
    elseif inside_code_block then
      table.insert(code_content, line)
    end
  end

  return code_content
end

-- Helper function to extract the type right after the variable name
local function extract_type_from_hover(hover_text, variable_name)
  -- Extract content only within code blocks
  local code_block_content = extract_code_block(hover_text)

  -- Join all code block content into a single string to handle multi-line types properly
  local cleaned_text = table.concat(code_block_content, " ")

  -- Normalize whitespace to make it cleaner
  cleaned_text = normalize_whitespace(cleaned_text)

  -- Look for the variable name and extract everything after it
  local type_info = cleaned_text:match(variable_name .. "%s*:%s*(.*)")

  -- If the type starts with a '(', we skip it (likely a function type)
  if type_info and type_info:match("^%s*%(") then
    return nil
  end

  return type_info
end

-- Function to get symbols from the document and show inlay hints for variable declarations
function M.show_inlay_hints()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Initialize the cache for the current buffer if it doesn't exist
  if not inlay_cache[bufnr] then
    inlay_cache[bufnr] = {}
  end

  -- Clear previous inlay hints
  clear_inlay_hints(bufnr)

  -- Request document symbols to find variable declarations
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
    textDocument = vim.lsp.util.make_text_document_params(),
  }, function(_, result, _, _)
    if not result then
      return
    end

    -- Iterate through the symbols to find variable declarations
    local function handle_symbols(symbols)
      for _, symbol in ipairs(symbols) do
        -- Check if the symbol is a variable (constant, let, var, or equivalent)
        if symbol.kind == 13 or symbol.kind == 6 then -- Variable or Constant in LSP spec
          local range = symbol.location and symbol.location.range or symbol.range
          if range then
            local row = range.start.line
            local col = range.start.character
            local variable_name = symbol.name

            -- Use hover to get type information for the variable
            vim.lsp.buf_request(bufnr, "textDocument/hover", {
              textDocument = vim.lsp.util.make_text_document_params(),
              position = { line = row, character = col },
            }, function(_, hover_result, _, _)
              if not (hover_result and hover_result.contents) then
                return
              end

              -- Convert the hover result to a list of lines
              local hover_text = vim.lsp.util.convert_input_to_markdown_lines(hover_result.contents)

              -- Extract the type information using the variable name
              local type_info = extract_type_from_hover(hover_text, variable_name)

              if not type_info then
                return
              end

              -- Check the cache to see if the hint for this line has changed
              if inlay_cache[bufnr][row] == type_info then
                return -- Skip rendering if the hint is the same as the cached one
              end

              -- Normalize strings before comparison to ensure consistent behavior
              local normalized_cached_hint = normalize_whitespace(inlay_cache[bufnr][row] or "")
              local normalized_current_hint = normalize_whitespace(type_info or "")

              -- Debugging: Display detailed info about the strings
              print("Cached hint:", normalized_cached_hint, "Length:", #normalized_cached_hint)
              print("Current hint:", normalized_current_hint, "Length:", #normalized_current_hint)

              -- Compare byte-by-byte if the strings appear identical
              if normalized_cached_hint == normalized_current_hint then
                for i = 1, math.max(#normalized_cached_hint, #normalized_current_hint) do
                  local cached_byte = normalized_cached_hint:byte(i) or "nil"
                  local current_byte = normalized_current_hint:byte(i) or "nil"
                  print(string.format("Byte %d - Cached: %s, Current: %s", i, cached_byte, current_byte))
                end
                return -- Skip rendering if the hint is the same as the cached one
              end

              -- Ensure the cache for the current buffer and line is properly initialized
              inlay_cache[bufnr] = inlay_cache[bufnr] or {}
              inlay_cache[bufnr][row] = type_info

              -- Use extmarks to display virtual text as an inlay hint
              vim.api.nvim_buf_set_extmark(bufnr, namespace, row, 0, {
                virt_text = { { type_info, "Comment" } },
                hl_mode = "combine",
              })
            end)
          end
        end

        -- Recursively handle children symbols if they exist
        if symbol.children then
          handle_symbols(symbol.children)
        end
      end
    end

    -- Process the symbols list
    handle_symbols(result)
  end)
end

-- Setup function to hook into relevant events
-- Attach autocommand to update inlay hints when the buffer is changed or cursor moves
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "InsertLeave", "DiagnosticChanged" }, {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" }, -- TypeScript and JavaScript files
  callback = function()
    M.show_inlay_hints()
  end,
})

-- Autocommand to detect text changes and mark the state as changed
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    M.show_inlay_hints()
  end,
})

-- Autocommands to control diagnostics updates
-- vim.cmd([[
--       augroup DiagnosticModeControl
--         autocmd!
--         " Disable diagnostics when entering insert mode
--         autocmd InsertEnter * lua vim.diagnostic.hide(nil, 0)
--         " Re-enable diagnostics when leaving insert mode
--         autocmd InsertLeave * lua vim.diagnostic.show(nil, 0)
--       augroup END
--     ]])
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   callback = function()
--     require("null-ls").disable()
--     vim.notify("none-ls disabled in Insert mode", vim.log.levels.INFO)
--   end,
--   desc = "Disable none-ls in Insert mode",
-- })

-- Autocmd to disable none-ls in Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    local null_ls = require("null-ls")
    if _G.none_ls_enabled then
      null_ls.disable({})
      -- vim.notify("none-ls disabled in Insert mode", vim.log.levels.INFO)
    end
  end,
  desc = "Disable none-ls in Insert mode",
})

-- Autocmd to restore none-ls state based on the toggle when leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    local null_ls = require("null-ls")
    if _G.none_ls_enabled then
      null_ls.enable({})
      -- vim.notify("none-ls enabled after Insert mode", vim.log.levels.INFO)
    end
  end,
  desc = "Restore none-ls state after Insert mode",
})
