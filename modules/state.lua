local M = {}

M.levels = {
    "test",
    "one",
    "two"
}

M.current_level_index = 3

M.current_level = M.levels[M.current_level_index]

M.info_box_text = {}

M.timer = {
    time = 0,
    is_running = false
}

return M