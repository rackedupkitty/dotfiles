return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd("hi clear")
        if vim.fn.exists("syntax_on") then
          vim.cmd("syntax reset")
        end
        vim.o.termguicolors = true
        vim.g.colors_name = "midnight_synth"

        -- =========================================================
        -- 2. THE KITTY ATOMIC PALETTE
        -- =========================================================
        local k = {
          bg = "#280D3E",
          fg = "#FFFFFF",
          c0 = "#3F2952",
          c8 = "#76578F", -- Dark Panels / Lines
          c1 = "#FFCCDB",
          c9 = "#F0AABE", -- Pinks
          c2 = "#ECCCFF",
          c10 = "#D5AAF0", -- Soft Lavenders
          c3 = "#E7CCFF",
          c11 = "#CFAAF0", -- Bright Lavenders
          c4 = "#C39AE6",
          c12 = "#C39AE6", -- Purple Blue
          c5 = "#C99AE6",
          c13 = "#C99AE6", -- Magentas
          c6 = "#C29AE6",
          c14 = "#C29AE6", -- Cyans
          c7 = "#FFCCDB",
          c15 = "#F0AABE", -- White-Pinks
          accent = "#7D46AE",
          cursor = "#9a0cde",
        }

        local hl = vim.api.nvim_set_hl

        local function nuke_ui()
          -- CORE UI (Reducing White)
          hl(0, "Normal", { fg = k.c10, bg = k.bg }) -- Normal text is now Lavender
          hl(0, "NormalFloat", { fg = k.c10, bg = k.bg })
          hl(0, "FloatBorder", { fg = k.c11, bg = k.bg })
          hl(0, "CursorLine", { bg = k.c0 })
          hl(0, "LineNr", { fg = k.c8 })

          -- DASHBOARD COLORS
          hl(0, "SnacksDashboardHeader", { fg = k.c13, bold = true }) -- Header is Magenta
          hl(0, "SnacksDashboardDesc", { fg = k.c10 }) -- Descriptions Lavender
          hl(0, "SnacksDashboardKey", { fg = k.c9, bold = true }) -- Keys are Pink

          -- THE COMMAND LINE (Noice)
          hl(0, "NoiceCmdline", { bg = k.c0, fg = k.c11 })
          hl(0, "NoiceCmdlinePopupBorder", { fg = k.c13 })
          hl(0, "NoiceCmdlineIcon", { fg = k.c9 })

          -- LAZY EXTRAS & MENUS (Killing Blue)
          hl(0, "LazySpecial", { fg = k.c12 })
          hl(0, "LazyValue", { fg = k.c10 })
          hl(0, "LazyDir", { fg = k.c14 })
          hl(0, "LazyButton", { bg = k.c0, fg = k.c10 })
          hl(0, "LazyButtonActive", { bg = k.accent, fg = k.fg })

          -- STATUSLINE FALLBACKS
          hl(0, "StatusLine", { bg = k.accent, fg = k.fg })
          hl(0, "StatusLineNC", { bg = k.c0, fg = k.c8 })

          -- FINAL BLUE CATCH-ALL
          local blue_groups = { "Identifier", "Special", "Type", "Function", "Directory", "Constant" }
          for _, group in ipairs(blue_groups) do
            hl(0, group, { fg = k.c12 })
          end
        end

        nuke_ui()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = nuke_ui })
      end,
    },
  },

  -- =========================================================
  -- 1. MLBVIM DASHBOARD LOGO (FIXED FOR SNACKS)
  -- =========================================================
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
 ███╗   ███╗██╗     ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗ ████║██║     ██╔══██╗██║   ██║██║████╗ ████║
 ██╔████╔██║██║     ██████╔╝██║   ██║██║██╔████╔██║
 ██║╚██╔╝██║██║     ██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚═╝ ██║███████╗██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝     ╚═╝╚══════╝╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
      },
    },
  },

  -- =========================================================
  -- 3. FIXED ICON CONFIG (Stop Rename Error)
  -- =========================================================
  {
    "nvim-mini/mini.icons", -- Correct name to stop the warning
    opts = {
      default = {
        file = { color = "#D5AAF0" },
        directory = { color = "#C39AE6" },
        extension = { color = "#F0AABE" },
      },
      style = "glam",
    },
  },

  -- =========================================================
  -- 4. LUALINE (Powerlevel10k / Kitty Style)
  -- =========================================================
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local k = { bg = "#280D3E", fg = "#FFFFFF", accent = "#7D46AE", panel = "#3F2952", pink = "#F0AABE" }
      opts.options.theme = {
        normal = {
          a = { bg = k.accent, fg = k.fg, bold = true },
          b = { bg = k.panel, fg = k.fg },
          c = { bg = k.bg, fg = k.fg },
        },
        insert = { a = { bg = k.pink, fg = k.bg, bold = true } },
        visual = { a = { bg = k.fg, fg = k.bg, bold = true } },
        replace = { a = { bg = "#FFCCDB", fg = k.bg, bold = true } },
      }
    end,
  },
}
