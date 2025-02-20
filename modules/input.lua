local M = {}

function M.init()
    msg.post(".", "acquire_input_focus")
	M.key_state = {
		left = false,
		right = false,
		crouch = false,

		action = false,
		run = false,
		attack = false
	}
end

function M.handle_key_state(flag_name, action)
	if action.pressed then
		M.key_state[flag_name] = true
		print(flag_name)
	elseif action.released then
		M.key_state[flag_name] = false
	end
end

function M.handle_key(flag_name, action_id, action)
	if action_id == hash(flag_name) then
		M.handle_key_state(flag_name, action)
	end
end

function M.capture(action_id, action)
	for direction, _ in pairs(M.key_state) do
		M.handle_key(direction, action_id, action)
	end
end

return M