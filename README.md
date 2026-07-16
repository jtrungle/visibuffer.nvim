# visibuffer.nvim

Open data files in [VisiData](https://visidata.org) inside a Neovim floating window.

Supports CSV, TSV, JSON, Parquet, SQLite, Excel, YAML, HDF5, PCAP, and more.

## Requirements

- Neovim >= 0.9
- [VisiData](https://visidata.org) (`pip install visidata`)

## Installation

### lazy.nvim

```lua
{
  dir = "/path/to/visibuffer.nvim",
  config = true,
}
```

## Usage

Opening a matching file (e.g. `data.csv`) automatically launches VisiData in a floating window.

| Action | Key |
|--------|-----|
| Open VisiData for current file | `<leader>Vd` or `:Visibuffer` |

VisiData opens in a terminal float. When you quit VisiData, the float closes and the file is ready to edit in Neovim. Running `:Visibuffer` again on the same file focuses the existing float.

## Configuration

```lua
require("visibuffer").setup({
  auto_quit = true,
  args = {},
  filetypes = {
    "*.csv", "*.tsv",
    "*.json", "*.jsonl",
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
})
```

| Option | Default | Description |
|--------|---------|-------------|
| `auto_quit` | `true` | Close float when VisiData exits |
| `args` | `{}` | Extra CLI args passed to visidata |
| `filetypes` | (see above) | File globs that trigger VisiData |
| `float.width` | `0.9` | Float width (fraction of editor or absolute px) |
| `float.height` | `0.9` | Float height (fraction of editor or absolute px) |
| `float.border` | `"rounded"` | Float border style |
| `float.title` | `" VisiData "` | Float title |
