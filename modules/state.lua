local M = {}

M.levels = {
    "test",
    "one"
}

M.current_level_index = 1

M.current_level = M.levels[M.current_level_index]

M.info_box_text = {}

return M