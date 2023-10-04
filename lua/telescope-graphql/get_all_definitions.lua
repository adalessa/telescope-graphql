local get_node_text = vim.treesitter.get_node_text

local get_definition_buffer = function(file)
    local uri = vim.uri_from_fname(file)
    local buff = vim.uri_to_bufnr(uri)
    vim.fn.bufload(buff)

    return buff
end


local get_graphql_definitions = function(bufnr)
    vim.treesitter.query.set(
        "yaml",
        "GraphQL_endpoints",
        [[
    (document (block_node (block_mapping (block_mapping_pair
        value: (block_node (block_mapping (block_mapping_pair
            value: (block_node (block_mapping (block_mapping_pair
                value: (block_node (block_mapping (block_mapping_pair
                    key: (flow_node) @mutation
                    value: (block_node (block_mapping (block_mapping_pair
                         key: (flow_node) @resolve (#eq? @resolve "resolve")
                         value: (flow_node) @resolver
                     )))
                )))
            )))
        )))
    ))))
        ]]
    )

    local query = vim.treesitter.query.get("yaml", "GraphQL_endpoints")

    local elements = {}

    local parsers = require "nvim-treesitter.parsers"
    local parser = parsers.get_parser(bufnr)
    local tree = parser:parse()[1]

    for id, node in query:iter_captures(tree:root(), bufnr) do
        if query.captures[id] == "mutation" then
            table.insert(elements, {
                value = get_node_text(node, bufnr),
                lnum = node:start() + 1,
                buffer = bufnr,
            })
        elseif query.captures[id] == "resolver" then
            elements[#elements].resolver = get_node_text(node, bufnr)
        end
    end

    return elements
end

local get_all_definitions = function(files)
    local definitions = {}
    for _, file in ipairs(files) do
        definitions = vim.fn.extend(definitions, get_graphql_definitions(get_definition_buffer(file)))
    end

    return definitions
end

return get_all_definitions
