# Neovim Plugin Enhancement Roadmap

### Phase 1: Core Editing (10 plugins)
**File**: `lua/plugins/editing-enhanced.lua`

- [ ] **nvim-surround** - Surround operations (`ys`, `ds`, `cs`)
- [ ] **nvim-various-textobjs** - 30+ text objects (iv=value, ik=key, ii=indent)
- [ ] **treesj** - Split/join code blocks (`<space>m` toggle)
- [ ] **substitute.nvim** - Better substitute/exchange (`s`, `sx`)
- [ ] **dial.nvim** - Smart increment/decrement (`<C-a>`, `<C-x>`)
- [ ] **iswap.nvim** - Interactive swap arguments (`<leader>is`)
- [ ] **sibling-swap.nvim** - Swap Tree-sitter nodes (`<leader>.`, `<leader>,`)
- [ ] **vim-visual-multi** - Multiple cursors (`<C-n>`)
- [ ] **nvim-treesitter-endwise** - Auto-add `end` in Ruby/Lua
- [ ] **harpoon** - Mark & jump to key files (`<leader>a`, `<C-h/j/k/l>`)

### Phase 1.5: Navigation (4 plugins)
**File**: `lua/plugins/navigation.lua`

- [ ] **oil.nvim** - Edit filesystem as buffer (`-` to open)
- [ ] **outline.nvim** - Symbol outline sidebar (`<leader>cs`)
- [ ] **refactoring.nvim** - Extract function/variable, inline
- [ ] **telescope-undo.nvim** - Undo tree visualizer (`<leader>su`)

---

### Phase 2: Git Workflow (7 plugins)
**File**: `lua/plugins/git-enhanced.lua`

- [ ] **lazygit.nvim** - Lazygit terminal UI (`<leader>gg`)
- [ ] **diffview.nvim** - Diff viewer (`<leader>gd` diff, `<leader>gh` history)
- [ ] **git-conflict.nvim** - Conflict resolution (`co` ours, `ct` theirs, `cn` next)
- [ ] **blame.nvim** - Inline git blame (`<leader>gb`)
- [ ] **fugit2.nvim** - Git graph & history (`<leader>gf`)
- [ ] **advanced-git-search.nvim** - Search commits (`<leader>gs`)
- [ ] **gitlinker.nvim** - Generate GitHub permalinks (`<leader>gy`)

---

### Phase 2.5: Docker & GitHub (7 plugins)
**File**: `lua/plugins/github-docker-enhanced.lua`

#### GitHub Integration
- [ ] **octo.nvim** - Full GitHub integration (PRs, issues, reviews, comments)
- [ ] **pipeline.nvim** - GitHub Actions workflow viewer & runner
- [ ] **gitlinker.nvim** - Generate GitHub/GitLab permalinks (already in Phase 2)
- [ ] **git-needy.nvim** - Statusbar workflow review counter

#### Docker Development
- [ ] **nvim-dev-container** - VSCode-like dev container support
- [ ] **dockerfile-language-server** (Mason) - Dockerfile LSP
- [ ] **hadolint** (Mason) - Dockerfile linter
- [ ] **actionlint** (Mason) - GitHub Actions workflow linter

#### Optional
- [ ] **gh-actions.nvim** - Tree-sitter grammar for Actions YAML (if you write many workflows)

---

### Phase 3: LSP & Diagnostics (10 plugins)
**File**: `lua/plugins/lsp-enhanced.lua`

- [ ] **tiny-inline-diagnostic.nvim** - Beautiful inline diagnostics
- [ ] **tiny-code-action.nvim** - Telescope-based code actions (`<leader>ca`)
- [ ] **nvim-rulebook** - Rule docs & inline ignores (`<leader>ri`, `<leader>rl`)
- [ ] **inc-rename.nvim** - Live preview LSP rename (`<leader>rn`)
- [ ] **symbol-usage.nvim** - Show references inline (CodeLens style)
- [ ] **nvim-lightbulb** - Code action indicator (lightbulb in sign column)
- [ ] **lsp-lens.nvim** - Function references above definitions
- [ ] **glance.nvim** - LSP locations preview window
- [ ] **lsp_signature.nvim** - Function signature help while typing
- [ ] **actions-preview.nvim** - Alternative code action preview (choose one with tiny-code-action)

---

### Phase 4: Debugging (6 plugins)
**File**: `lua/plugins/debugging.lua`

- [ ] **nvim-dap** - Debug Adapter Protocol core
- [ ] **nvim-dap-ui** - Beautiful debugging UI
- [ ] **nvim-dap-virtual-text** - Show variable values inline
- [ ] **telescope-dap.nvim** - Browse DAP with Telescope
- [ ] **mason-nvim-dap.nvim** - Auto-install DAP adapters
- [ ] **nvim-dap-repl-highlights** - REPL syntax highlighting

**DAP Adapters** (via mason-nvim-dap):
- `debugpy` (Python)
- `codelldb` (Rust, C/C++, Zig)
- `delve` (Go)
- `java-debug-adapter` (Java)
- `node-debug2-adapter` (JS/TS)
- `bash-debug-adapter` (Bash)

---

### Phase 5: Testing (10 plugins)
**File**: `lua/plugins/testing.lua`

- [ ] **neotest** - Universal test runner framework
- [ ] **nvim-nio** - Async IO library (neotest dependency)
- [ ] **neotest-python** - pytest & unittest support
- [ ] **neotest-go** - Go testing support
- [ ] **neotest-jest** - Jest test runner
- [ ] **neotest-vitest** - Vitest test runner
- [ ] **neotest-playwright** - Playwright E2E tests
- [ ] **neotest-rust** - Rust cargo test support
- [ ] **neotest-rspec** - Ruby RSpec support
- [ ] **nvim-coverage** - Test coverage display

---

### Phase 6: Language-Specific (11 plugins)

#### C/C++ (`lua/plugins/language-enhanced/c-cpp-enhanced.lua`)
- [ ] **clangd_extensions.nvim** - Off-spec clangd features
- [ ] **compiler.nvim** - Build/run C/C++ projects

#### Python (`lua/plugins/language-enhanced/python-enhanced.lua`)
- [ ] **venv-selector.nvim** - Virtual environment selector
- [ ] **python-import.nvim** - Auto-add Python imports

#### Go (`lua/plugins/language-enhanced/go-enhanced.lua`)
- [ ] **go.nvim** - Comprehensive Go tooling
- [ ] **gotests.nvim** - Generate Go tests
- [ ] **goplements.nvim** - Visualize implementations

#### Rust (`lua/plugins/language-enhanced/rust-enhanced.lua`)
- [ ] **rustaceanvim** - Better rust-analyzer integration
- [ ] **crates.nvim** - Manage Cargo.toml dependencies

#### TypeScript/JavaScript (`lua/plugins/language-enhanced/typescript-enhanced.lua`)
- [ ] **typescript-tools.nvim** - Faster TypeScript LSP
- [ ] **tsc.nvim** - Async TypeScript type checking
- [ ] **package-info.nvim** - Show package versions in package.json

#### Java (`lua/plugins/language-enhanced/java-enhanced.lua`)
- [ ] **nvim-java** - Complete Java support (wraps nvim-jdtls)

**Note**: Zig, Ruby, Bash already well-supported via LSP/Tree-sitter. No additional plugins needed.

---

### Phase 7: UI & Quality of Life (18 plugins)
**File**: `lua/plugins/ui-enhanced.lua`

#### UI Enhancements
- [ ] **nvim-notify** - Beautiful notifications (pairs with noice.nvim)
- [ ] **dressing.nvim** - Better vim.ui.select/input
- [ ] **statuscol.nvim** - Enhanced sign column
- [ ] **colorful-winsep.nvim** - Colored window separators
- [ ] **incline.nvim** - Floating statuslines per window
- [ ] **zen-mode.nvim** - Distraction-free mode (`<leader>z`)
- [ ] **twilight.nvim** - Dim inactive code blocks
- [ ] **rainbow-delimiters.nvim** - Rainbow brackets
- [ ] **hlchunk.nvim** - Indent highlighting

#### Utilities (`lua/plugins/utilities.lua`)
- [ ] **nvim-early-retirement** - Auto-close unused buffers
- [ ] **mini.bufremove** - Smart buffer deletion (`<leader>bd`)
- [ ] **nvim-bqf** - Enhanced quickfix window
- [ ] **telescope-zoxide** - Zoxide directory jumping (`<leader>fz`)
- [ ] **smart-open.nvim** - Frecency-based file finder (`<leader>fo`)
- [ ] **text-case.nvim** - Case conversion (camelCase, snake_case)
- [ ] **yanky.nvim** - Yank/paste history with ring navigation
- [ ] **nvim-neoclip.lua** - Clipboard manager with Telescope (`<leader>fy`)

---

### Phase 8: Specialized Tools (22 plugins)

#### Markdown (`lua/plugins/markdown-enhanced.lua`)
- [ ] **render-markdown.nvim** - Beautiful in-editor rendering
- [ ] **markdown.nvim** - Enhanced Markdown tools (links, lists, tables)
- [ ] **markdown-preview.nvim** - Browser preview (`<leader>mp`)
- [ ] **nvim-toc** - Table of contents generator
- [ ] **nvim-FeMaco.lua** - Edit code blocks in separate buffers

#### REPL (`lua/plugins/repl.lua`)
- [ ] **iron.nvim** - REPL support (Python, Lua, etc.)
- [ ] **sniprun** - Run code snippets instantly

#### Project Management (`lua/plugins/project.lua`)
- [ ] **project.nvim** - Automatic project detection
- [ ] **workspaces.nvim** - Workspace/session management
- [ ] **projections.nvim** - Project-specific settings

#### Search & Replace (`lua/plugins/search-replace.lua`)
- [ ] **nvim-spectre** - Advanced search & replace UI (`<leader>sr`)
- [ ] **ssr.nvim** - Structural search & replace (Tree-sitter based)

**Note**: Already have grug-far.nvim, so spectre is optional alternative

#### Terminal (`lua/plugins/terminal.lua`)
- [ ] **toggleterm.nvim** - Better terminal management
- [ ] **flatten.nvim** - Open files from terminal in parent nvim

#### HTTP Client (`lua/plugins/specialized.lua`)
- [ ] **rest.nvim** - HTTP client for REST API testing
- [ ] **kulala.nvim** - Alternative HTTP client (choose one)

#### Code Runner
- [ ] **code_runner.nvim** - Quick code execution per filetype
- [ ] **overseer.nvim** - Task runner framework

---

## 📝 Optional Plugins (Add Later If Needed)

These are lower priority or use-case specific:

- [ ] **molten-nvim** - Jupyter notebook support (only if you use Jupyter)
- [ ] **obsidian.nvim** - Obsidian vault integration (only if you use Obsidian)
- [ ] **vim-rails** - Rails enhancements (only if you do Rails)
- [ ] **leetcode.nvim** - LeetCode integration (only if you practice)
- [ ] **mini.animate** - Smooth scrolling (may impact performance)
- [ ] **ldelossa/gh.nvim** - Alternative GitHub code review (if octo.nvim isn't enough)
- [ ] **copilot.lua** - GitHub Copilot (you already have 99.lua + opencode)

---

## ⚙️ Configuration Files Map

```
~/.config/nvim/lua/plugins/
├── editing-enhanced.lua           # Phase 1 (10 plugins)
├── navigation.lua                 # Phase 1.5 (4 plugins)
├── git-enhanced.lua               # Phase 2 (7 plugins)
├── github-docker-enhanced.lua     # Phase 2.5 (7 plugins)
├── lsp-enhanced.lua               # Phase 3 (10 plugins)
├── debugging.lua                  # Phase 4 (6 plugins)
├── testing.lua                    # Phase 5 (10 plugins)
├── ui-enhanced.lua                # Phase 7 (9 plugins)
├── utilities.lua                  # Phase 7 (9 plugins)
├── markdown-enhanced.lua          # Phase 8 (5 plugins)
├── repl.lua                       # Phase 8 (2 plugins)
├── project.lua                    # Phase 8 (3 plugins)
├── search-replace.lua             # Phase 8 (2 plugins)
├── terminal.lua                   # Phase 8 (2 plugins)
├── specialized.lua                # Phase 8 (4 plugins)
└── language-enhanced/
    ├── c-cpp-enhanced.lua         # Phase 6 (2 plugins)
    ├── python-enhanced.lua        # Phase 6 (2 plugins)
    ├── go-enhanced.lua            # Phase 6 (3 plugins)
    ├── rust-enhanced.lua          # Phase 6 (2 plugins)
    ├── typescript-enhanced.lua    # Phase 6 (3 plugins)
    └── java-enhanced.lua          # Phase 6 (1 plugin)
```

---

## 📝 Plugin Details Reference

Quick lookup when configuring. Only critical plugins listed:

### nvim-surround
- **Repo**: kylechui/nvim-surround
- **Keys**: `ys{motion}{char}` add, `ds{char}` delete, `cs{old}{new}` change
- **Example**: `ysiw"` surround word with quotes, `ds"` delete quotes
- **Docs**: https://github.com/kylechui/nvim-surround

### nvim-various-textobjs
- **Repo**: chrisgrieser/nvim-various-textobjs
- **Objects**: `iv` value, `ik` key, `ii` indent, `in` number, `iS` subword, `ie` entire buffer
- **Example**: `div` delete value, `cik` change key
- **Docs**: https://github.com/chrisgrieser/nvim-various-textobjs

### treesj
- **Repo**: Wansmer/treesj
- **Keys**: `<space>m` toggle, `<space>j` join, `<space>s` split
- **Example**: Toggle array between single/multi-line
- **Docs**: https://github.com/Wansmer/treesj

### harpoon
- **Repo**: ThePrimeagen/harpoon (branch: harpoon2)
- **Keys**: `<leader>a` add mark, `<C-h/j/k/l>` jump to marks 1-4
- **Example**: Mark 4 key files, quickly jump between them
- **Docs**: https://github.com/ThePrimeagen/harpoon/tree/harpoon2

### lazygit.nvim
- **Repo**: kdheepak/lazygit.nvim
- **Keys**: `<leader>gg` open lazygit
- **Requires**: lazygit installed (`brew install lazygit` or `apt install lazygit`)
- **Docs**: https://github.com/kdheepak/lazygit.nvim

### diffview.nvim
- **Repo**: sindrets/diffview.nvim
- **Keys**: `<leader>gd` diff, `<leader>gh` file history
- **Commands**: `:DiffviewOpen`, `:DiffviewFileHistory`
- **Docs**: https://github.com/sindrets/diffview.nvim

### octo.nvim
- **Repo**: pwntester/octo.nvim
- **Commands**: `:Octo pr list`, `:Octo issue list`, `:Octo pr checkout`
- **Requires**: GitHub CLI (`gh`) installed
- **Docs**: https://github.com/pwntester/octo.nvim

### pipeline.nvim
- **Repo**: topaxi/pipeline.nvim
- **Commands**: View GitHub Actions workflows, logs, re-run jobs
- **Requires**: GitHub CLI (`gh`) installed
- **Docs**: https://github.com/topaxi/pipeline.nvim

### nvim-dap + nvim-dap-ui
- **Repos**: mfussenegger/nvim-dap, rcarriga/nvim-dap-ui
- **Keys**: `<F5>` continue, `<F10>` step over, `<F11>` step into, `<F9>` toggle breakpoint
- **Requires**: Language-specific debuggers via Mason
- **Docs**: https://github.com/mfussenegger/nvim-dap

### neotest
- **Repo**: nvim-neotest/neotest
- **Keys**: `<leader>tt` run test, `<leader>tf` run file, `<leader>ts` toggle summary
- **Requires**: Language-specific adapters
- **Docs**: https://github.com/nvim-neotest/neotest

### oil.nvim
- **Repo**: stevearc/oil.nvim
- **Keys**: `-` open oil in current directory
- **Usage**: Edit filesystem like a buffer (rename, delete, move files)
- **Docs**: https://github.com/stevearc/oil.nvim

---

## 🎯 Key Decisions Locked In

- ✅ **Treesj** over mini.splitjoin (more powerful)
- ✅ **Lazygit** for git UI (user preference)
- ✅ **Harpoon** for file navigation (over grapple)
- ✅ **Iron.nvim** for REPL (over yarepl)
- ✅ **Project.nvim** for project detection
- ✅ **Octo.nvim** for GitHub (industry standard)
- ✅ **Pipeline.nvim** for GitHub Actions
- ✅ **Nvim-dev-container** for Docker (over nvim-remote-containers)
- ✅ **Yanky.nvim** for yank history (nvim-neoclip as optional alternative)
- ✅ **Rest.nvim** for HTTP client (kulala as optional alternative)

---

## 📚 Essential Resources

- **LazyVim Docs**: https://www.lazyvim.org/
- **Lazy.nvim**: https://github.com/folke/lazy.nvim
- **Mason**: https://github.com/williamboman/mason.nvim
- **Awesome Neovim**: https://github.com/rockerBOO/awesome-neovim

