local M = {}

M.defaults = {
  auto_quit = true,
  args = {},
  filetypes = {
    "*.csv", "*.tsv",
    "*.parquet", "*.feather", "*.arrow",
    "*.yaml", "*.yml",
    "*.xlsx", "*.xls",
    "*.sqlite", "*.sqlite3", "*.db",
    "*.h5", "*.hdf5",
    "*.pcap",
  },
  float = {
    width = 0.9,
    height = 0.9,
    border = "rounded",
    title = " VisiData ",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
