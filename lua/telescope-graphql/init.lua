local action_set = require "telescope.actions.set"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local get_all_definitions = require "telescope-graphql.get_all_definitions"
local pickers = require "telescope.pickers"

return function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = 'GraphQL',
        finder = finders.new_table {
            results = get_all_definitions(opts.files),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.value,
                    ordinal = entry.value,
                    path = vim.api.nvim_buf_get_name(entry.buffer),
                    lnum = entry.lnum,
                    resolver = entry.resolver,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
        attach_mappings = function()
            action_set.select:enhance {
                post = function()
                    local selection = action_state.get_selected_entry()
                    vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                end,
            }
            return true
        end,
    }):find()
end
