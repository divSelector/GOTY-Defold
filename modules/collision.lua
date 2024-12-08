local M = {}

local collision_bits = {
    PLAYER = 1,    -- (2^0)
    GROUND = 2,    -- (2^1)
}

local tile_width = 16
local tile_height = 16

local tile_insert_x_offet = 0
local tile_insert_y_offet = 0
local tile_insert_x_offet = 8
local tile_insert_y_offet = 29

local tile_draw_x_offset = 0
local tile_draw_y_offset = 0
local tile_draw_x_offset = -8
local tile_draw_y_offset = -9

local debug = true

local entity_width = 46
local entity_height = 54

local half_entity_width = entity_width / 2
local half_entity_height = entity_height / 2

function M.init()
    M.group = daabbcc.new_group(daabbcc.UPDATE_INCREMENTAL)

    M.player_aabb_id = nil

    M.ground_data = {}
end

function M.add_tilemap(tilemap_url, layer)
    local x, y, w, h = tilemap.get_bounds(tilemap_url)

    for row = y, y + h - 1 do
        for col = x, x + w - 1 do
            local tile_index = tilemap.get_tile(tilemap_url, layer, col, row)
            if tile_index == 17 then -- ground tile hard coded?
                local tile_x = (col - 1) * tile_width + tile_insert_x_offet
                local tile_y = (row - 1) * tile_height + tile_insert_y_offet

                local aabb_id = daabbcc.insert_aabb(M.group, tile_x, tile_y, tile_width, tile_height, collision_bits.GROUND)

                -- Store tile data
                M.ground_data[aabb_id] = { type = "GROUND", x = tile_x, y = tile_y, width = tile_width, height = tile_height }
            end
        end
    end
end


function M.add_player(player_url)
    M.player_aabb_id = daabbcc.insert_gameobject(M.group, player_url, entity_width, entity_height, collision_bits.PLAYER)
end

local function debug_draw_aabb(aabb_data, color, offset_x, offset_y)
    offset_x = offset_x or 0
    offset_y = offset_y or 0
    for _, data in pairs(aabb_data) do
        local x, y = data.x + offset_x, data.y + offset_y
        local width, height = data.width, data.height

        msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x + width, y, 0), color = color })
        msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x, y + height, 0), color = color })
        msg.post("@render:", "draw_line", { start_point = vmath.vector3(x + width, y, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
        msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y + height, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
    end
end


local function debug_draw_raycast(ray_start, ray_end, color)
    msg.post("@render:", "draw_line", { start_point = ray_start, end_point = ray_end, color = color })
end


function M.raycast_player(player_pos, sprite_flipped, max_distance)

    local direction = sprite_flipped and -1 or 1

    local ray_offsets = {
        0,                       -- center
        half_entity_height - 10,  -- top
        -half_entity_height + 10  -- bottom
    }

    local results = {}

    for _, offset in ipairs(ray_offsets) do
        local ray_start = vmath.vector3(player_pos.x, player_pos.y + offset, 0)
        local ray_end = vmath.vector3(player_pos.x + direction * max_distance, player_pos.y + offset, 0)

        local result, count = daabbcc.raycast(M.group, ray_start.x, ray_start.y, ray_end.x, ray_end.y, collision_bits.GROUND)
        
        table.insert(results, {result = result, count = count, ray_start = ray_start, ray_end = ray_end})
    end

    if debug then
        local blue = vmath.vector4(0, 0, 1, 1)

        for _, ray_data in ipairs(results) do
            debug_draw_raycast(ray_data.ray_start, ray_data.ray_end, blue)

            if ray_data.count then
                for _, aabb_id in ipairs(ray_data.result) do
                    local tile = M.ground_data[aabb_id]
                    if tile then
                        debug_draw_aabb({ tile }, blue, tile_draw_x_offset, tile_draw_y_offset)
                    end
                end
            end
        end
    end

    return results
end



function M.update_wall_contact(player, player_pos)

    local raycast_results = M.raycast_player(player_pos, player.sprite_flipped, 26)

    player.wall_contact_left = false
    player.wall_contact_right = false

    for _, result in ipairs(raycast_results) do
        if result.result then
            if player.sprite_flipped then
                player.wall_contact_left = true
            else
                player.wall_contact_right = true
            end
        end
    end
end


function M.debug_draw(player_pos)
    local red = vmath.vector4(1, 0, 0, 1)
    local green = vmath.vector4(0, 1, 0, 1)
    
    debug_draw_aabb(M.ground_data, red, tile_draw_x_offset, tile_draw_y_offset)
    debug_draw_aabb({ { 
        x = player_pos.x - half_entity_width,
        y = player_pos.y - half_entity_height,
        width = entity_width,
        height = entity_height
    } }, green)
end

function M.query_player()
    local result, count = daabbcc.query_id_sort(M.group, M.player_aabb_id, collision_bits.GROUND)
    return result, count
end

return M