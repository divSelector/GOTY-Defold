local utils = require "modules.utils"

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

local entity_width = 18
local entity_height = 46

local half_entity_width = entity_width / 2
local half_entity_height = entity_height / 2

local TILES = {
    GROUND = 17,
    SPRING = 88
}

function M.init()
    M.group = daabbcc.new_group(daabbcc.UPDATE_INCREMENTAL)

    M.player_aabb_id = nil

    M.tile_data = {}
end

function M.add_tilemap(tilemap_url, layer)
    local x, y, w, h = tilemap.get_bounds(tilemap_url)

    for row = y, y + h - 1 do
        for col = x, x + w - 1 do
            local tile_index = tilemap.get_tile(tilemap_url, layer, col, row)
            local tile_type = utils.get_key_by_value(TILES, tile_index)

            if TILES[tile_type] then

                local tile_x = (col - 1) * tile_width + tile_insert_x_offet
                local tile_y = (row - 1) * tile_height + tile_insert_y_offet

                local aabb_id = daabbcc.insert_aabb(M.group, tile_x, tile_y, tile_width, tile_height, collision_bits.GROUND)

                -- Store tile data
                M.tile_data[aabb_id] = { type = tile_type, x = tile_x, y = tile_y, width = tile_width, height = tile_height }
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
        half_entity_height - 4,  -- top
        -half_entity_height + 4  -- bottom
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
                    local tile = M.tile_data[aabb_id]
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

    local raycast_results = M.raycast_player(player_pos, player.sprite_flipped, half_entity_width + 1)

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
    
    debug_draw_aabb(M.tile_data, red, tile_draw_x_offset, tile_draw_y_offset)
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

function M.check(entity, pos)
    local query_result, result_count = M.query_player()

    if not query_result and (entity.wall_contact_left or entity.wall_contact_right) then
        print("No query result")
        entity.wall_contact_left = false
        entity.wall_contact_right = false
    end

    if query_result and result_count > 0 then
        local first_collision = query_result[1]
        local aabb_id = first_collision.id
        local data = M.tile_data[aabb_id]

        if data and data.type == "GROUND" then
            local y_offset = 18
            -- local x_offset = 15.01
            local tile_top = data.y + data.height
            local tile_bottom = data.y
            local tile_left = data.x
            local tile_right = data.x + data.width

            -- local tile_left_offset = 15.01  -- correct numbers for width 46
            -- local tile_right_offset = 31.01

            local tile_top_offset = 14
            local tile_bottom_offset = 32

            local tile_right_offset = 1.01   -- correct numbers for width 18
            local tile_left_offset = 17.01

            -- Check for above and below collisions
            local is_above_tile = pos.y >= tile_top
            local is_below_tile = pos.y + (half_entity_height) < tile_bottom
            local is_right_of_tile = pos.x - (half_entity_width) < tile_right and pos.x > tile_left
            local is_left_of_tile = pos.x + (half_entity_width) + 1000000 > tile_left and pos.x < tile_right


            -- Handle collision from above (landing)
            if is_above_tile then
                -- print("Hit from above")
                -- pos.y = tile_top + y_offset
                pos.y = tile_top + tile_top_offset
                entity.ground_contact = true
                msg.post("/camera#controller", "follow_player_y", { toggle = false })
                entity.velocity.y = 0

            -- Handle collision from below
            elseif is_below_tile then
                -- print("Hit from below")
                pos.y = tile_bottom - tile_bottom_offset
                entity.velocity.y = 0
                entity.is_jumping = false

            -- Handle left collision
            elseif is_right_of_tile then
                -- pos.x = tile_right + x_offset
                pos.x = tile_right + tile_right_offset
                entity.velocity.x = 0
                entity.wall_contact_left = true

            -- Handle right collision
            elseif is_left_of_tile then
                -- pos.x = tile_left - (x_offset * 2) - 1
                pos.x = tile_left - tile_left_offset
                entity.velocity.x = 0
                entity.wall_contact_right = true
            end
        else
            print("Unknown collision!")
        end
    end
    
    return pos
end



return M