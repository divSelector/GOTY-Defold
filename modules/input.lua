local state = require "modules.state"
local utils = require "modules.utils"

local M = {}

local LEFT_MOUSE = hash("mouse_button_left")
local MIDDLE_MOUSE = hash("mouse_button_middle")
local RIGHT_MOUSE = hash("mouse_button_right")
local WHEEL_UP = hash("mouse_wheel_up")
local WHEEL_DOWN = hash("mouse_wheel_down")
local TEXT = hash("text")
local KEY_SHIFT = hash("key_shift")
local KEY_CTRL = hash("key_ctrl")
local KEY_ALT = hash("key_alt")
local KEY_SUPER = hash("key_super")

local IMGUI_KEYS = {
	[hash("key_tab")] = imgui.KEY_TAB,
	[hash("key_left")] = imgui.KEY_LEFTARROW,
	[hash("key_right")] = imgui.KEY_RIGHTARROW,
	[hash("key_up")] = imgui.KEY_UPARROW,
	[hash("key_down")] = imgui.KEY_DOWNARROW,
	[hash("key_pageup")] = imgui.KEY_PAGEUP,
	[hash("key_pagedown")] = imgui.KEY_PAGEDOWN,
	[hash("key_home")] = imgui.KEY_HOME,
	[hash("key_end")] = imgui.KEY_END,
	[hash("key_insert")] = imgui.KEY_INSERT,
	[hash("key_delete")] = imgui.KEY_DELETE,
	[hash("key_backspace")] = imgui.KEY_BACKSPACE,
	[hash("key_space")] = imgui.KEY_SPACE,
	[hash("key_enter")] = imgui.KEY_ENTER,
	[hash("key_esc")] = imgui.KEY_ESCAPE,
	[hash("key_numpad_enter")] = imgui.KEY_KEYPADENTER,
	[hash("key_a")] = imgui.KEY_A,
	[hash("key_c")] = imgui.KEY_C,
	[hash("key_v")] = imgui.KEY_V,
	[hash("key_x")] = imgui.KEY_X,
	[hash("key_y")] = imgui.KEY_Y,
	[hash("key_z")] = imgui.KEY_Z,
}

M.keybind_to_string = {
    [hash("key_left")] = "key_left",
    [hash("key_right")] = "key_right",
    [hash("key_down")] = "key_down",
    [hash("key_x")] = "key_x",
    [hash("key_a")] = "key_a",
    [hash("key_z")] = "key_z"
}

M.waiting_for_key = false

M.keybind_order = {
	"left",
	"right",
	"crouch",
	"action",
	"run",
	"attack"
}

M.key_state = {
	left = false,
	right = false,
	crouch = false,
	action = false,
	run = false,
	attack = false
}

M.keybinds = {
	left = hash("key_left"),
	right = hash("key_right"),
	crouch = hash("key_down"),
	action = hash("key_x"),
	run = hash("key_a"),
	attack = hash("key_z")
}

local unbindable_keys = {
	hash("touch"),
	hash("key_esc")
}

function M.init()
    msg.post(".", "acquire_input_focus")
end

function M.update_keybind(action, new_key)

	local new_key_string = utils.extract_key_from_hash_string(tostring(new_key))

    if new_key_string:sub(1, 5) == "mouse" then
        print("Mouse inputs cannot be bound!")
        return
    end

	for _, unbindable in ipairs(unbindable_keys) do
        if new_key == unbindable then
            print("This key cannot be bound!")
            return
        end
    end

	for other_action, other_binding in pairs(M.keybinds) do
		if other_binding == new_key then
			M.keybinds[other_action] = M.keybinds[action]
		end
	end

    M.keybinds[action] = new_key
    M.keybind_to_string[new_key] = new_key -- Store readable name
end

function M.handle_key_state(flag_name, action)
	if action.pressed then
		M.key_state[flag_name] = true
	elseif action.released then
		M.key_state[flag_name] = false
	end
end

function M.handle_key(flag_name, action_id, action)
	if action_id == M.keybinds[flag_name] then
		M.handle_key_state(flag_name, action)
	end
end

function M.capture_player(action_id, action)
	for direction, _ in pairs(M.key_state) do
		M.handle_key(direction, action_id, action)
	end
end

function M.capture(action_id, action)
	M.capture_imgui(action_id, action)

	if state.is_paused and M.waiting_for_key and action.pressed then
		if action.pressed and M.waiting_for_key then
			M.update_keybind(M.waiting_for_key, action_id)
			M.waiting_for_key = nil -- Reset waiting state after key is set
		end
	else
		M.capture_player(action_id, action)
	end
end

function M.capture_imgui(action_id, action)
	if action_id == LEFT_MOUSE then
		if action.pressed then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_LEFT, 1)
		elseif action.released then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_LEFT, 0)
		end
	elseif action_id == MIDDLE_MOUSE then
		if action.pressed then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_MIDDLE, 1)
		elseif action.released then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_MIDDLE, 0)
		end
	elseif action_id == RIGHT_MOUSE then
		if action.pressed then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_RIGHT, 1)
		elseif action.released then
			imgui.set_mouse_button(imgui.MOUSEBUTTON_RIGHT, 0)
		end
	elseif action_id == WHEEL_UP then
		imgui.set_mouse_wheel(action.value)
	elseif action_id == WHEEL_DOWN then
		imgui.set_mouse_wheel(-action.value)
	elseif action_id == TEXT then
		imgui.add_input_character(action.text)
	elseif action_id == KEY_SHIFT then
		if action.pressed or action.released then
			imgui.set_key_modifier_shift(action.pressed == true)
		end
	elseif action_id == KEY_CTRL then
		if action.pressed or action.released then
			imgui.set_key_modifier_ctrl(action.pressed == true)
		end
	elseif action_id == KEY_ALT then
		if action.pressed or action.released then
			imgui.set_key_modifier_alt(action.pressed == true)
		end
	elseif action_id == KEY_SUPER then
		if action.pressed or action.released then
			imgui.set_key_modifier_super(action.pressed == true)
		end
	else
		if action.pressed or action.released then
			local key = IMGUI_KEYS[action_id]
			if key then
				imgui.set_key_down(key, action.pressed == true)
			end
		end
	end

	if not action_id then
		local w, h = window.get_size()
		local x = action.screen_x
		local y = h - action.screen_y
		imgui.set_mouse_pos(x, y)
	end
end


return M