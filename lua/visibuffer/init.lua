local config = require("visibuffer.config")

local api = vim.api
local fn = vim.fn
local log = vim.log

local M = {}

M._float = nil

function M.setup(opts)
  config.setup(opts)

  local group = api.nvim_create_augroup("Visibuffer", { clear = true })

  local pattern = table.concat(config.options.filetypes, ",")

  api.nvim_create_autocmd("BufReadPost", {
    group = group,
    pattern = pattern,
    desc = "Open data files with VisiData",
    callback = function()
      M._sched_float(fn.expand("<afile>"))
    end,
  })

  api.nvim_create_user_command("Visibuffer", function()
    M.open_with_visidata(api.nvim_buf_get_name(0))
  end, { desc = "Open current file with VisiData", force = true })

  vim.keymap.set("n", "<leader>Vd", "<cmd>Visibuffer<CR>",
    { desc = "Open VisiData for current file" })
end

function M._clean_float()
  if not M._float then return true end
  local win_ok = api.nvim_win_is_valid(M._float.win)
  local buf_ok = api.nvim_buf_is_valid(M._float.buf)
  if not win_ok or not buf_ok then
    if buf_ok then
      api.nvim_buf_delete(M._float.buf, { force = true })
    end
    M._float = nil
    return true
  end
  return false
end

function M._close_float()
  if not M._float then return end
  if api.nvim_win_is_valid(M._float.win) then
    api.nvim_win_close(M._float.win, true)
  end
  if api.nvim_buf_is_valid(M._float.buf) then
    api.nvim_buf_delete(M._float.buf, { force = true })
  end
  M._float = nil
end

function M._sched_float(filepath)
  if fn.executable("visidata") == 0 then return end

  vim.schedule(function()
    M.open_with_visidata(filepath)
  end)
end

function M._float_dimensions()
  local owidth = config.options.float.width
  local oheight = config.options.float.height
  local ew = vim.o.columns
  local eh = vim.o.lines - 2

  local width = math.floor(type(owidth) == "number" and owidth <= 1 and ew * owidth or owidth)
  local height = math.floor(type(oheight) == "number" and oheight <= 1 and eh * oheight or oheight)
  local row = math.floor((eh - height) / 2)
  local col = math.floor((ew - width) / 2)

  return { width = width, height = height, row = row, col = col }
end

function M._open_float(cmd, filepath)
  local buf = api.nvim_create_buf(false, true)
  local dim = M._float_dimensions()

  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = dim.width,
    height = dim.height,
    row = dim.row,
    col = dim.col,
    style = "minimal",
    border = config.options.float.border,
    title = config.options.float.title,
  })

  M._float = { win = win, buf = buf, file = filepath }

  api.nvim_win_set_option(win, "winhl", "NormalFloat:NormalFloat,FloatBorder:FloatBorder")

  local job_id = fn.termopen(cmd, {
    on_exit = function()
      if not config.options.auto_quit then return end
      M._close_float()
    end,
  })

  if job_id == 0 then
    vim.notify("visibuffer: failed to start visidata", log.levels.ERROR)
    M._close_float()
    return
  end

  vim.cmd("startinsert")
end

function M._build_cmd(filepath)
  if #config.options.args > 0 then
    return "visidata " .. table.concat(config.options.args, " ") .. " " .. fn.shellescape(filepath)
  end
  return "visidata " .. fn.shellescape(filepath)
end

function M.open_with_visidata(filepath)
  if not filepath or filepath == "" then
    vim.notify("visibuffer: no file to open", log.levels.ERROR)
    return
  end

  if fn.executable("visidata") == 0 then
    vim.notify("visibuffer: 'visidata' not found in PATH", log.levels.WARN)
    return
  end

  if M._clean_float() then
    M._open_float(M._build_cmd(filepath), filepath)
    return
  end

  if M._float.file == filepath then
    api.nvim_set_current_win(M._float.win)
    return
  end

  M._close_float()
  M._open_float(M._build_cmd(filepath), filepath)
end

return M
