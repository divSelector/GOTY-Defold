local M = {}

M.levels = {
    "test",
    "one",
    "two"
}

M.current_level_index = 1

M.current_level = M.levels[M.current_level_index]

M.info_box_text = {}

M.timer = {
    time = 0,
    is_running = false
}

M.victory = false

M.is_paused = false
M.pause_allowed = true

M.difficulty_level = 1

return M