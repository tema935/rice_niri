-- ~/.config/nvim/init.lua
-- Минимальный конфиг на Lazy.nvim + colorizer (простая настройка)
-- Добавлено автодополнение командной строки (cmp-cmdline)

-- Устанавливаем Lazy.nvim, если его нет
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Базовые настройки
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Сохранение (Ctrl+S)
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file (normal)" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file and switch to normal mode" })
vim.keymap.set("v", "<C-s>", "<cmd>w<CR>", { desc = "Save file (visual)" })

-- Выход (Ctrl+Q) — осторожно, может закрыть окно!
vim.keymap.set({ "n", "i", "v" }, "<C-q>", "<cmd>qa<CR>", { desc = "Quit all" })

-- Плагины
require("lazy").setup({
	-- Тема gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("gruvbox")
		end,
	},

	-- Mason (установка LSP серверов, линтеров и т.д.)
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},

	-- Интеграция Mason c lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = { "lua_ls", "ts_ls", "rust_analyzer" },
			})

			-- Безопасно вызываем setup_handlers, если функция существует
			pcall(function()
				mason_lspconfig.setup_handlers({
					function(server_name)
						if not vim.lsp.config[server_name] then
							local settings = require("mason-lspconfig").get_server_settings(server_name)
							vim.lsp.config[server_name] = { cmd = settings.cmd }
						end
						vim.lsp.enable(server_name)
					end,
				})
			end)
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
			if not ok then
				return
			end
			ts_configs.setup({
				ensure_installed = { "lua", "vim", "javascript", "typescript", "rust" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- nvim-cmp (ядро автодополнения)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Источник для путей (то, что тебе нужно)
			"hrsh7th/cmp-path",
			-- Источник для слов из буфера (полезно)
			"hrsh7th/cmp-buffer",
			-- Источник для командной строки (добавлено)
			"hrsh7th/cmp-cmdline",
			-- Для красивого меню (опционально)
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")

			-- Базовые настройки внешнего вида (как в твоём прошлом конфиге)
			vim.opt.completeopt = { "menu", "menuone", "noselect" }

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					-- Accept (выбрать вариант)
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					-- Next / Previous
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					-- Scroll docs
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
				}),
				sources = cmp.config.sources({
					{ name = "path" }, -- автодополнение путей!
					{ name = "buffer" }, -- слова из открытых файлов
				}, {
					{ name = "luasnip" }, -- сниппеты
				}),
			})

			-- Настройка автодополнения командной строки (:)
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "cmdline" },
				}),
			})

			-- Опционально: автодополнение для поиска (/)
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		end,
	},

	-- Автопары
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Комментирование
	{
		"numToStr/Comment.nvim",
		config = true,
	},

	-- LSP-маппинги
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})
		end,
	},

	-- Форматтеры
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					rust = { "rustfmt" },
				},
				format_on_save = { timeout_ms = 500, lsp_fallback = true },
			})
		end,
	},
	-- Линтеры
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				javascript = { "eslint" },
				typescript = { "eslint" },
				lua = { "luacheck" }, -- <-- эта строка требует установленного luacheck
			}
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	-- Подсветка hex-цветов — УПРОЩЁННЫЙ ВАРИАНТ
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup() -- без аргументов = работает для всех файлов
		end,
	},
}, {
	install = { colorscheme = { "gruvbox" } },
	checker = { enabled = true, notify = false },
})

print("Neovim config loaded   (no warnings!) & Hello my new version")
