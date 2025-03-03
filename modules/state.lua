local M = {}

M.levels = {
    "test",
    "two",
    "one"
}

M.current_level_index = 1
M.spawn_point = 1

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

M.selected_base = 3
M.selected_body = 17
M.selected_head = 17
M.selected_accessory = 17

M.ball_count = 0
M.total_balls = 0

return M