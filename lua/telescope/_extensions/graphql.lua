return require("telescope").register_extension {
  exports = {
    definitions = require "telescope-graphql",
  },
}
