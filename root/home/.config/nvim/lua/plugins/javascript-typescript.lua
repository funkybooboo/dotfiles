return {
  -- ts_ls: type checking, completions, go-to-definition, inlay hints.
  -- For the erledigen monorepo ts_ls picks up the per-workspace tsconfig.json
  -- (project references under apps/* and packages/*) via its default
  -- root_dir detection, so cross-package imports resolve.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "js-debug-adapter",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
      })
    end,
  },

  -- Formatting: `biome-check` runs format + lint-fix + organize-imports, the
  -- same operation `mise run check` performs, so the editor and `mise run
  -- check` always agree. conform's built-in `biome-check` formatter already
  -- prefers `node_modules/.bin/biome` (util.from_node_modules) and uses
  -- biome.json as cwd, so the pinned repo version is used with no override.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "biome-check" },
        javascriptreact = { "biome-check" },
        typescript = { "biome-check" },
        typescriptreact = { "biome-check" },
        json = { "biome-check" },
        jsonc = { "biome-check" },
      },
    },
  },

  -- Linting: Biome via the `gitlab` reporter, which emits stable JSON (an
  -- array of {description,check_name,severity,location.{path,lines.begin}}).
  -- We define a COMPLETE linter (not an override) so we never depend on the
  -- built-in `biome` linter being loaded at merge time -- LazyVim's nvim-lint
  -- merge would otherwise replace the built-in's parser with our partial
  -- table. The `cmd` always prefers the repo-local node_modules/.bin/biome
  -- (matches the pinned version), and `condition` no-ops outside biome
  -- projects. We omit `cwd`: nvim-lint requires it to be a string; biome
  -- discovers biome.json by walking up from the (absolute) linter file
  -- argument, so no cwd is needed.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
      },
      linters = {
        biome = {
          cmd = function()
            local root = vim.fs.root(0, { "biome.json", "biome.jsonc", ".biome.json" })
            if root then
              local local_biome = root .. "/node_modules/.bin/biome"
              if vim.fn.executable(local_biome) == 1 then
                return local_biome
              end
            end
            return "biome" -- Mason or system biome fallback
          end,
          args = { "lint", "--reporter=gitlab" },
          stdin = false, -- nvim-lint appends the buffer filename
          stream = "stdout",
          ignore_exitcode = true, -- biome exits non-zero when errors exist
          -- NOTE: nvim-lint requires `cwd` to be a STRING (it is passed to
          -- `:cd` and libuv spawn); a function cwd silently breaks the run.
          -- Biome resolves biome.json by walking up from the linter file
          -- argument (the absolute buffer path nvim-lint appends), so the
          -- current working directory is not needed for config discovery.
          condition = function(ctx)
            return vim.fs.find(
              { "biome.json", "biome.jsonc", ".biome.json" },
              { path = ctx.filename, upward = true }
            )[1] ~= nil
          end,
          parser = function(output)
            local diagnostics = {}
            if output == nil or output == "" then
              return diagnostics
            end
            local ok, data = pcall(vim.json.decode, output)
            if not ok or type(data) ~= "table" then
              return diagnostics
            end
            local sev_map = {
              critical = vim.diagnostic.severity.ERROR,
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              info = vim.diagnostic.severity.INFO,
            }
            for _, d in ipairs(data) do
              local begin = (d.location and d.location.lines and d.location.lines.begin) or 1
              local sev = sev_map[d.severity] or vim.diagnostic.severity.ERROR
              table.insert(diagnostics, {
                lnum = begin - 1, -- gitlab lines are 1-indexed
                col = 0,
                severity = sev,
                message = d.description or d.check_name or "biome",
                code = d.check_name,
                source = "biome",
              })
            end
            return diagnostics
          end,
        },
      },
    },
  },
}