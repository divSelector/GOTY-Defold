local utils = require "modules.utils"

local M = {}

local collision_bits = {
    PLAYER     = 1,  -- (2^0)
    GROUND     = 2,  -- (2^1)
    PROJECTILE = 4,  -- (2^2)
    ENEMY =      8,  -- (2^3)
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

local projectile_width = 26
local projectile_height = 14

-- correction numbers for entity_width 18
local tile_top_offset = 14
local tile_bottom_offset = 32
local tile_right_offset = 1.01
local tile_left_offset = 17.01
-- local tile_top_offset = 0
-- local tile_bottom_offset = 0
-- local tile_right_offset = 0
-- local tile_left_offset = 0

local TILES = {
    GROUND = 17,
    SPRING = 88,
    QUESTION = 33
}

function M.init()
    M.group = daabbcc.new_group(daabbcc.UPDATE_INCREMENTAL)

    M.player_aabb_id = nil

    M.tile_data = {}
    M.projectile_data = {}
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
                M.tile_data[aabb_id] = { index = tile_index, x = tile_x, y = tile_y, width = tile_width, height = tile_height }
            end
        end
    end
end

function M.add_player(player_url)
    local player_aabb_id = daabbcc.insert_gameobject(M.group, player_url, entity_width, entity_height, collision_bits.PLAYER)
    return player_aabb_id
end

function M.add_enemy(enemy_url)
    local enemy_aabb_id = daabbcc.insert_gameobject(M.group, enemy_url, entity_width, entity_height, collision_bits.ENEMY)
    return enemy_aabb_id
end

function M.add_platform(platform_url)
    local mask_bits = bit.bor(collision_bits.ENEMY, collision_bits.PLAYER, collision_bits.GROUND)
    local enemy_aabb_id = daabbcc.insert_gameobject(M.group, platform_url, 16, 16, mask_bits)
    return enemy_aabb_id
end

function M.add_projectile(projectile_url)
    local projectile_aabb_id = daabbcc.insert_gameobject(M.group, projectile_url, projectile_width, projectile_height, collision_bits.PROJECTILE)
    return projectile_aabb_id
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

function M.raycast_player_x(player_pos, sprite_flipped, max_distance)

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


function M.raycast_player_y(player_pos, max_distance)

    local direction = -1  -- down only for now

    local ray_offsets = {
        half_entity_width - 4,  -- left
        -half_entity_width + 4  -- right
    }

    local results = {}

    for _, offset in ipairs(ray_offsets) do
        local ray_start = vmath.vector3(player_pos.x + offset, player_pos.y, 0)
        local ray_end = vmath.vector3(player_pos.x + offset, player_pos.y + direction * max_distance, 0)

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


local function get_tile_dimensions(data)
    if data then
        local tile_top = data.y + data.height
        local tile_bottom = data.y
        local tile_left = data.x
        local tile_right = data.x + data.width

        return tile_top, tile_bottom, tile_left, tile_right
    end
end


function M.update_wall_contact(entity, entity_pos)

    local x_raycast_results = M.raycast_player_x(entity_pos, entity.sprite_flipped, half_entity_width + 1)

    entity.wall_contact_left = false
    entity.wall_contact_right = false

    for _, result in ipairs(x_raycast_results) do
        if result.result then
            if entity.sprite_flipped then
                entity.wall_contact_left = true
            else
                entity.wall_contact_right = true
            end
        end
    end

    -- for now we're not really doing anything with this part below here.
    -- i can't reliably produce the bug I'm trying to fix so idk
    -- consider taking this out if it's not going to do anything
    -- edit: the only thing it's doing it lowering the velocity
    if entity.velocity.y >= 0 then return end

    local y_raycast_results = M.raycast_player_y(entity_pos, half_entity_height + 20)

    for _, result in ipairs(y_raycast_results) do
        if result.count then
            for _, aabb_id in ipairs(result.result) do
                local tile = M.tile_data[aabb_id]
                if tile then
                    -- local tile_top, tile_bottom, tile_left, tile_right = get_tile_dimensions(tile)
                    -- entity_pos.y = tile_top + tile_top_offset
                    -- entity.ground_contact = true
                    if entity.velocity.y > 500 then
                        entity.velocity.y = math.floor(entity.velocity.y / 2)
                    end
                end
            end
        end
    end

end

function M.debug_draw(player_pos)

    if not debug then return end

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

function M.query(aabb_id, mask)
    local mask = mask or collision_bits.GROUND
    local result, count = daabbcc.query_id_sort(M.group, aabb_id, mask)
    return result, count
end

function M.check_projectile(projectile)
    query_result, result_count = M.query(projectile.aabb_id)
    if query_result and result_count > 0 then
        projectile.lifetime = 0
    end
end



function M.check_entity(entity, pos, is_player)
    local query_result, result_count = M.query(entity.aabb_id)

    if not query_result and (entity.wall_contact_left or entity.wall_contact_right) then
        entity.wall_contact_left = false
        entity.wall_contact_right = false
    end

    if query_result and result_count > 0 then
        for _, overlap in ipairs(query_result) do
            local aabb_id = overlap.id
            local data = M.tile_data[aabb_id]
    
            if not data then return end
    
            local tile_top, tile_bottom, tile_left, tile_right = get_tile_dimensions(data)
    
            local is_above_tile = pos.y >= tile_top
            local is_below_tile = pos.y + (half_entity_height) < tile_bottom
            local is_right_of_tile = pos.x - (half_entity_width) < tile_right and pos.x > tile_left
            local is_left_of_tile = pos.x + (half_entity_width) + 1000000 > tile_left and pos.x < tile_right
    
            if is_above_tile then
                pos.y = tile_top + tile_top_offset
                entity.ground_contact = true
                if is_player then
                    msg.post("/camera#controller", "follow_player_y", { toggle = false })
                end
                entity.velocity.y = 0
    
            elseif is_below_tile then
                pos.y = tile_bottom - tile_bottom_offset
                entity.velocity.y = 0
                entity.is_jumping = false
    
            elseif is_right_of_tile then
                pos.x = tile_right + tile_right_offset
                entity.velocity.x = 0
                entity.wall_contact_left = true
    
            elseif is_left_of_tile then
                pos.x = tile_left - tile_left_offset
                entity.velocity.x = 0
                entity.wall_contact_right = true
            end
    
            -- if not is_player then return end
    
            if data.index == TILES.SPRING and is_above_tile then
                msg.post("/camera#controller", "follow_player_y", { toggle = true })
                entity.velocity.y = 750
            
            elseif data.index == TILES.QUESTION and is_below_tile then
                msg.post("#skins", "randomize_skin")
    
            else
                -- print("Unknown collision!")
            end
        end

    end
    
    return pos
end

function M.destroy(aabb_id)
    daabbcc.remove(M.group, aabb_id)
end

return M