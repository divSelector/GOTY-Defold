local socket = require "socket"

local M = {}

M.gates = {}

local collection = "main"
local gameobject = "/audio"

local gate_times = {
    default = 0.3,
    decay = 0.6
}

local function gate(gate_key)
    local current_time = socket.gettime()
    if M.gates[gate_key] and (current_time < M.gates[gate_key]) then
        print("Sound " .. gate_key .. " is still gated.")
        return false
    end
    local gate_time = gate_times[gate_key] or gate_times["default"]
    M.gates[gate_key] = current_time + gate_time
    return true
end

function M.play_sound(soundcomponent, gain, category)
    local gate_key = category or soundcomponent
    local play = gate(gate_key)
    if play then
        local url = msg.url(collection, gameobject, soundcomponent)
        local gain = gain or 1.0
        sound.play(url, { gain = gain })
    end
end

function M.stop_sound(soundcomponent)
    local url = msg.url(collection, gameobject, soundcomponent)
    sound.stop(url)
end

-- example of function that handles a category of sounds.
-- function M.play_enemy_death()

--     math.randomseed(os.time())

--     local index = math.random(1, 5)
--     local sound_key = "death_" .. index
--     local gain = 1.0
--     local category = "enemy_death"

--     M.play_sound(sound_key, gain, category)

-- end

-- -- note: we removed the update and on_message functions from docs example

return M