require('catppuccin').setup({
    show_end_of_buffer = true,
    integrations = {
        treesitter = true,
        harpoon = true,
        mason = true,
        telescope = {
            enabled = true,
            -- style = "nvchad"
        },
    }
})

function ColorMe(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)
end

ColorMe()
