local utils = require "modules.utils"
local state = require "modules.state"
local audio = require "modules.audio"


local M = {}

local collision_bits = {
    PLAYER     = 1, -- (2^0)
    GROUND     = 2, -- (2^1)
    PROJECTILE = 4, -- (2^2)
    ENEMY      = 8, -- (2^3)
    PASSABLE   = 16 -- (2^4)
}

M.TILES = {
    GROUND = 17,
    SPRING = 88,
    QUESTION = 33,
    INFO = 34,
    BUSH = { 50, 66, 82 }
}

local TILE_COLLISION_BITS = {
    GROUND = collision_bits.GROUND,
    SPRING = collision_bits.GROUND,
    QUESTION = collision_bits.GROUND,
    INFO = collision_bits.GROUND,
    BUSH = collision_bits.PASSABLE
}

local tile_width = 16
local tile_height = 16

local tile_insert_x_offet = 0
local tile_insert_y_offet = 0
local tile_insert_x_offet = 8
local tile_insert_y_offet = 9

local tile_draw_x_offset = 0
local tile_draw_y_offset = 0
local tile_draw_x_offset = -8
local tile_draw_y_offset = -9

local debug = false

local entity_width = 18
local entity_height = 46

local half_entity_width = entity_width / 2
local half_entity_height = entity_height / 2

local projectile_width = 26
local projectile_height = 14

-- correction numbers for entity_width 18
local tile_top_offset = 14
local tile_bottom_offset = -32
local tile_right_offset = 1.01
local tile_left_offset = -17.01

local red = vmath.vector4(1, 0, 0, 1)
local green = vmath.vector4(0, 1, 0, 1)

-- NOTES DO NOT PROCESS ANY SIMPLE TOUCHING COLLISION LIKE PROJECTILES AND BALLS IN THE PART WHERE WE PROCESS AND DO TILE PLATFORM CORRECTION

local enemy_aabb_id_to_urls = {}

local function is_tile(tile, tiles_enum)
    for _, value in ipairs(tiles_enum) do
        if tile == value then
            return true
        end
    end
    return false
end

function M.init()
    M.group = daabbcc.new_group(daabbcc.UPDATE_INCREMENTAL)

    M.player_aabb_id = nil

    M.tile_data = {}
    M.platform_ids = {}
    M.ball_ids = {}
end

function M.add_tilemap(tilemap_url, layer)
    local x, y, w, h = tilemap.get_bounds(tilemap_url)
    M.map = { x = x, y = y, w = w, h = h }

    for row = y, y + h - 1 do
        for col = x, x + w - 1 do
            local tile_index = tilemap.get_tile(tilemap_url, layer, col, row)
            local tile_type = utils.get_key_by_value(M.TILES, tile_index)

            if M.TILES[tile_type] then
                local tile_x = (col - 1) * tile_width + tile_insert_x_offet
                local tile_y = (row - 1) * tile_height + tile_insert_y_offet

                local aabb_id = daabbcc.insert_aabb(M.group, tile_x, tile_y, tile_width, tile_height,
                    TILE_COLLISION_BITS[tile_type])

                M.tile_data[aabb_id] = {
                    index = tile_index,
                    x = tile_x,
                    y = tile_y,
                    width = tile_width,
                    height = tile_height
                }
            end
        end
    end
end

function M.add_player(player_url)
    local player_aabb_id = daabbcc.insert_gameobject(M.group, player_url, entity_width, entity_height,
        collision_bits.PLAYER)
    return player_aabb_id
end

function M.add_enemy(enemy_url)
    local enemy_aabb_id = daabbcc.insert_gameobject(M.group, enemy_url, entity_width, entity_height, collision_bits
    .ENEMY)
    enemy_aabb_id_to_urls[enemy_aabb_id] = enemy_url
    return enemy_aabb_id
end

function M.add_platform(platform_url)
    local platform_aabb_id = daabbcc.insert_gameobject(M.group, platform_url, 16, 16, collision_bits.GROUND)
    M.platform_ids[platform_aabb_id] = platform_url
    return platform_aabb_id
end

function M.add_projectile(projectile_url)
    local projectile_aabb_id = daabbcc.insert_gameobject(M.group, projectile_url, projectile_width, projectile_height,
        collision_bits.PROJECTILE)
    return projectile_aabb_id
end

function M.add_ball(ball_url)
    local ball_aabb_id = daabbcc.insert_gameobject(M.group, ball_url, 11, 11, collision_bits.GROUND)
    return ball_aabb_id
end

function M.add_checkpoint(checkpoint_url)
    local checkpoint_aabb_id = daabbcc.insert_gameobject(M.group, checkpoint_url, 11, 11, collision_bits.PASSABLE)
    return checkpoint_aabb_id
end

local function debug_draw_aabb(aabb_data, color, offset_x, offset_y)
    offset_x = offset_x or 0
    offset_y = offset_y or 0
    for _, data in pairs(aabb_data) do
        local x, y = data.x + offset_x, data.y + offset_y
        local width, height = data.width, data.height

        msg.post("@render:", "draw_line",
            { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x + width, y, 0), color = color })
        msg.post("@render:", "draw_line",
            { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x, y + height, 0), color = color })
        msg.post("@render:", "draw_line",
            { start_point = vmath.vector3(x + width, y, 0), end_point = vmath.vector3(x + width, y + height, 0), color =
            color })
        msg.post("@render:", "draw_line",
            { start_point = vmath.vector3(x, y + height, 0), end_point = vmath.vector3(x + width, y + height, 0), color =
            color })
    end
end

local function debug_draw_raycast(ray_start, ray_end, color)
    msg.post("@render:", "draw_line", { start_point = ray_start, end_point = ray_end, color = color })
end

local function raycast_x(player_pos, sprite_flipped, max_distance, ray_offsets)
    local direction = sprite_flipped and -1 or 1

    local ray_offsets = ray_offsets or {
        8,                      -- above center
        0,                      -- center
        half_entity_height - 4, -- top
        -half_entity_height + 4 -- bottom
    }

    local results = {}

    for _, offset in ipairs(ray_offsets) do
        local ray_start = vmath.vector3(player_pos.x, player_pos.y + offset, 0)
        local ray_end = vmath.vector3(player_pos.x + direction * max_distance, player_pos.y + offset, 0)

        local result, count = daabbcc.raycast(M.group, ray_start.x, ray_start.y, ray_end.x, ray_end.y,
            collision_bits.GROUND)

        table.insert(results, { result = result, count = count, ray_start = ray_start, ray_end = ray_end })
    end

    if debug then
        local blue = vmath.vector4(0, 0, 1, 1)

        for _, ray_data in ipairs(results) do
            debug_draw_raycast(ray_data.ray_start, ray_data.ray_end, blue)

            if ray_data.count then
                for _, aabb_id in ipairs(ray_data.result) do
                    local tile = M.tile_data[aabb_id]
                    local platform = M.platform_ids[aabb_id]
                    if tile then
                        debug_draw_aabb({ tile }, blue, tile_draw_x_offset, tile_draw_y_offset)
                    elseif platform then
                        local platform_pos = go.get_position(platform)
                        debug_draw_aabb({ {
                            x = platform_pos.x - 8 + tile_insert_x_offet,
                            y = platform_pos.y - 8 + tile_insert_y_offet,
                            width = tile_width,
                            height = tile_height
                        } }, blue, tile_draw_x_offset, tile_draw_y_offset)
                    end
                end
            end
        end
    end

    return results
end

local function raycast_y(player_pos, max_distance, direction)
    local x_offsets = {
        half_entity_width - 4, -- left
        -half_entity_width + 4 -- right
    }

    local y_start_offet = half_entity_height / 2

    local results = {}

    for _, x_offset in ipairs(x_offsets) do
        local ray_start = vmath.vector3(player_pos.x + x_offset, player_pos.y - y_start_offet, 0)
        local ray_end = vmath.vector3(player_pos.x + x_offset, player_pos.y + direction * max_distance, 0)

        local result, count = daabbcc.raycast(M.group, ray_start.x, ray_start.y, ray_end.x, ray_end.y,
            collision_bits.GROUND)

        table.insert(results, { result = result, count = count, ray_start = ray_start, ray_end = ray_end })
    end

    if debug then
        local blue = vmath.vector4(0, 0, 1, 1)

        for _, ray_data in ipairs(results) do
            debug_draw_raycast(ray_data.ray_start, ray_data.ray_end, blue)

            if ray_data.count then
                for _, aabb_id in ipairs(ray_data.result) do
                    local tile = M.tile_data[aabb_id]
                    local platform = M.platform_ids[aabb_id]
                    if tile then
                        debug_draw_aabb({ tile }, blue, tile_draw_x_offset, tile_draw_y_offset)
                    elseif platform then
                        local platform_pos = go.get_position(platform)
                        debug_draw_aabb({ {
                            x = platform_pos.x - 8 + tile_insert_x_offet,
                            y = platform_pos.y - 8 + tile_insert_y_offet,
                            width = tile_width,
                            height = tile_height
                        } }, blue, tile_draw_x_offset, tile_draw_y_offset)
                    end
                end
            end
        end
    end

    return results
end

local function get_tile_dimensions(data, aabb_id)
    if data then
        return {
            index = data.index,
            top = data.y + data.height,
            bottom = data.y,
            left = data.x,
            right = data.x + data.width,
            x = data.x,
            y = data.y,
            aabb_id = aabb_id
        }
    end
end

local function get_platform_dimensions(url)
    if go.exists(url) then
        local data = go.get_position(url)
        local script_url = url
        script_url.fragment = "platform"
        return {
            index = go.get(script_url, "tile_index"),
            velocity = go.get(script_url, "velocity"),
            top = data.y + tile_height,
            bottom = data.y,
            left = data.x,
            right = data.x + tile_width,
            x = data.x,
            y = data.y
        }
    end
end

local function get_ground_orientation(data, pos)
    return {
        is_above_tile = pos.y >= data.top,
        is_below_tile = pos.y + (half_entity_height) < data.bottom,
        is_right_of_tile = pos.x - (half_entity_width) < data.right and pos.x > data.left,
        is_left_of_tile = pos.x + (half_entity_width) + 1000000 > data.left and pos.x < data.right
    }
end

local function handle_overlap(entity, entity_pos, tile, orientation, is_player)
    if not tile or not orientation then return end

    if tile.index == M.TILES.SPRING and not orientation.is_below_tile then
        msg.post("/camera#controller", "follow_player_y", { toggle = true })
        entity.velocity.y = 600
        entity.can_jump = false
        audio.play_sound("spring")
    elseif is_player and is_tile(tile.index, M.TILES.BUSH) then
        entity.decay_momentum()
    end
end

local function handle_ground_contact(entity, entity_pos, tile, orientation, is_player)
    if not tile or not orientation then return end

    if tile.index == M.TILES.SPRING and not orientation.is_below_tile then
        msg.post("/camera#controller", "follow_player_y", { toggle = true })
        entity.velocity.y = 600
        entity.can_jump = false
        audio.play_sound("spring")
        return
    end

    if orientation.is_above_tile then
        entity.velocity.y = 0
        entity_pos.y = tile.top + tile_top_offset
        entity.ground_contact = true

        if tile.index == 3 and tile.velocity and is_player then
            msg.post("/player#player", "match_platform_velocity", {
                velocity = tile.velocity
            })
        end

        if is_player then
            msg.post("/camera#controller", "follow_player_y", { toggle = false })
        end
    end

end

local function handle_ceiling_contact(entity, entity_pos, tile, orientation)

    local tile_x = math.floor((tile.x - M.map.x * tile_width) / tile_width) + 2
    local tile_y = math.floor((tile.y - M.map.y * tile_height) / tile_height) + 2

    local did_sound_play = false

    local function bonk(tile_index, action_index)
        audio.play_sound("bonk")
        did_sound_plau = true
        local action_index = action_index or 1
        tilemap.set_tile("/level#tilemap", "ground", tile_x, tile_y, 0)
        M.tile_data[tile.aabb_id].index = 17
        factory.create("/level#block_factory", vmath.vector3(tile.x, tile.y, 0), nil, {
            tile_x = tile_x,
            tile_y = tile_y,
            tile_index = 17,
            action_index = action_index
        })
    end

    if not tile or not orientation then return end

    if not orientation.is_below_tile then return end

    entity.velocity.y = 0
    entity.is_jumping = false

    entity_pos.y = tile.bottom + tile_bottom_offset

    if tile.index == M.TILES.QUESTION then
        bonk(tile.index)
        msg.post("#skins", "randomize_skin")

    elseif tile.index == M.TILES.INFO then
        bonk(tile.index)

        msg.post("main:/main#dialog", "play_dialog", {
            dialog = state.info_box_text[tile_x .. "," .. tile_y]
        })
    end

    if not did_sound_play then
        audio.play_sound("bonk-inert")
    end
end

local function handle_forward_wall_contact(entity, entity_pos, tile, orientation)
    if not tile or not orientation then return end

    entity.velocity.x = 0
    entity.knockback_velocity = nil

    local facing_right = entity.sprite_flipped

    if facing_right and orientation.is_right_of_tile then
        -- print("left")
        entity_pos.x = tile.right + tile_right_offset
        entity.wall_contact_left = true
    elseif not facing_right and orientation.is_left_of_tile then
        -- print("right")
        entity_pos.x = tile.left + tile_left_offset
        entity.wall_contact_right = true
    end
end

local function handle_backward_wall_contact(entity, entity_pos, tile, orientation)
    if not tile or not orientation then return end

    entity.knockback_velocity = nil

    if entity.sprite_flipped then
        entity_pos.x = tile.left + tile_left_offset
        entity.wall_contact_right = true
    else
        entity_pos.x = tile.right + tile_right_offset
        entity.wall_contact_left = true
    end
end

local function normalize(results)
    local normalized = {}

    if results then
        for _, result in ipairs(results) do
            if result.result then -- raycast
                for _, aabb_id in ipairs(result.result) do
                    table.insert(normalized, aabb_id)
                end
            elseif result.id then -- overlap
                table.insert(normalized, result.id)
            end
        end
    end

    return normalized
end

local function _process(normalized_ids, pos, callback)
    for _, aabb_id in ipairs(normalized_ids) do
        local tile = M.tile_data[aabb_id]
        local platform = M.platform_ids[aabb_id]

        if tile or platform then
            local dimensions
            if tile then
                dimensions = get_tile_dimensions(tile, aabb_id)
            else
                dimensions = get_platform_dimensions(platform)
            end

            local orientation = get_ground_orientation(dimensions, pos)

            callback(dimensions, orientation)
        end
    end
end


local function handle_high_velocity_fix(entity)
    entity.velocity.y = math.floor(entity.velocity.y / 2)
end

local query_handlers = {
    overlap = handle_overlap,
    forward_wall = handle_forward_wall_contact,
    backward_wall = handle_backward_wall_contact,
    ground = handle_ground_contact,
    ceiling = handle_ceiling_contact,
    high_velocity_ground_fix = handle_high_velocity_fix,
    high_velocity_ceiling_fix = handle_high_velocity_fix
}


function M.handle(entity, entity_pos, is_player)
    local function process(results, callback)
        local normalized_results = normalize(results)

        if utils.is_table_empty(normalized_results) then
            return true
        end

        _process(normalized_results, entity_pos, function(dimensions, orientation)
            callback(entity, entity_pos, dimensions, orientation, is_player)
        end)
    end

    local function reset()
        entity.ground_contact = false
        entity.wall_contact_left = false
        entity.wall_contact_right = false
    end

    reset()


    local ray_x_offets
    local ray_ceiling_distance

    if entity.is_crouching then
        ray_x_offets = {
            8,                      -- above center
            0,                      -- center
            -half_entity_height + 4 -- bottom
        }
        ray_ceiling_distance = 4
    elseif entity.is_prone then
        ray_x_offets = {
            -half_entity_height + 4 -- bottom
        }
        ray_ceiling_distance = -8
    else
        ray_x_offets = {
            8,                       -- above center
            0,                       -- center
            -8,                      -- below center
            half_entity_height - 10, -- top
            -half_entity_height + 6  -- bottom (moved up for clearing crouch slide over gaps)
        }
        ray_ceiling_distance = half_entity_height - 2
    end

    local queries = {}

    if is_player then
        queries = {
            overlap = M.query(entity.aabb_id),
            ground = raycast_y(entity_pos, half_entity_height + 1, -1),
            ceiling = raycast_y(entity_pos, ray_ceiling_distance, 1),
            forward_wall = raycast_x(entity_pos, entity.sprite_flipped, half_entity_width + 1, ray_x_offets),
            backward_wall = raycast_x(entity_pos, not entity.sprite_flipped, half_entity_width + 1, ray_x_offets)
        }
    else
        queries = {
            ground = raycast_y(entity_pos, half_entity_height + 1, -1),
            ceiling = raycast_y(entity_pos, ray_ceiling_distance, 1)
        }
    end

    if entity.velocity.y < -300 then
        queries.high_velocity_ground_fix = raycast_y(entity_pos, half_entity_height + 10, -1)
    elseif entity.velocity.y > 300 then
        queries.high_velocity_ceiling_fix = raycast_y(entity_pos, half_entity_height + 10, 1)
    end


    for query_name, handler in pairs(query_handlers) do
        if queries[query_name] then
            process(queries[query_name], handler)
        end
    end


    if is_player and entity.is_prone then
        if entity.platform_velocity then return end

        local headroom_distance = 0

        local stand_up_headroom_query = raycast_y(entity_pos, ray_ceiling_distance, headroom_distance)
        local no_collision = process(stand_up_headroom_query, function()
            if entity.slide_timer > 0 then return end

            entity.is_prone_without_headroom = true
            if entity.is_prone_direction == nil then
                entity.is_prone_direction = entity.sprite_flipped and 1 or -1
            end
        end)
        if no_collision then
            entity.is_prone_without_headroom = false
            entity.is_prone_direction = nil
        end
    end
end

function M.handle_platform(platform, pos, vel)
    local function process(results, callback)
        local normalized_results = normalize(results)
        _process(normalized_results, pos, function(dimensions, orientation)
            callback(platform, pos, dimensions, orientation, false)
        end)
    end

    local direction_x
    if vel.x < 0 then
        direction_x = true
    elseif vel.x > 0 then
        direction_x = false
    end

    local queries = {
        wall = raycast_x(pos, direction_x, 8 + 1, { 0 })
    }

    process(queries.wall, function(platform, pos, dimensions, orientation)
        if dimensions.index == M.TILES.GROUND then
            msg.post(platform.id, "reverse_direction")
        end
    end)
end

function M.debug_draw_player(player_pos)
    if not debug then return end

    debug_draw_aabb(M.tile_data, red, tile_draw_x_offset, tile_draw_y_offset)
    debug_draw_aabb({ {
        x = player_pos.x - half_entity_width,
        y = player_pos.y - half_entity_height,
        width = entity_width,
        height = entity_height
    } }, green)
end

function M.debug_draw_level(enemies, platforms)
    if not debug then return end

    for _, enemy in ipairs(enemies) do
        local enemy_go = go.get_position(enemy)
        debug_draw_aabb({ {
            x = enemy_go.x - half_entity_width,
            y = enemy_go.y - half_entity_height,
            width = entity_width,
            height = entity_height
        } }, green)
    end

    for _, platform in ipairs(platforms) do
        local platform_go = go.get_position(platform)
        debug_draw_aabb({ {
            x = platform_go.x - 8,
            y = platform_go.y - 8,
            width = 16,
            height = 16
        } }, red)
    end
end

function M.query(aabb_id, mask_bits)
    local mask_bits = mask_bits or bit.bor(collision_bits.GROUND, collision_bits.PASSABLE)
    local result, count = daabbcc.query_id_sort(M.group, aabb_id, mask_bits)
    return result, count
end

function M.query_ball(aabb_id)
    local mask_bits = bit.bor(collision_bits.PLAYER)
    local result, count = daabbcc.query_id_sort(M.group, aabb_id, mask_bits)
    return result, count
end

function M.query_checkpoint_player(aabb_id)
    local mask_bits = bit.bor(collision_bits.PLAYER)
    local result, count = daabbcc.query_id_sort(M.group, aabb_id, mask_bits)
    return result, count
end

function M.query_checkpoint_ground(aabb_id)
    local mask_bits = bit.bor(collision_bits.GROUND)
    local result, count = daabbcc.query_id_sort(M.group, aabb_id, mask_bits)
    return result, count
end

function M.check_ball(ball)
    query_result, result_count = M.query_ball(ball.aabb_id)
    if query_result and result_count > 0 then
        msg.post(ball.id, "collect")
    end
end

function M.check_checkpoint(checkpoint)
    query_result, result_count = M.query_checkpoint_player(checkpoint.aabb_id)
    if query_result and result_count > 0 then
        msg.post(checkpoint.id, "collect")
    end

    query_result, result_count = M.query_checkpoint_ground(checkpoint.aabb_id)
    if query_result and result_count > 0 then
        msg.post(checkpoint.id, "stop_fall")
        return true
    end
end

function M.check_projectile_entity(projectile, from_player, projectile_velocity)
    local mask_bits
    if from_player then
        mask_bits = collision_bits.ENEMY
    else
        mask_bits = collision_bits.PLAYER
    end
    query_result, result_count = M.query(projectile.aabb_id, mask_bits)
    if query_result and result_count > 0 then
        projectile.lifetime = 0
        local entity_url
        if from_player then
            entity_url = enemy_aabb_id_to_urls[query_result[1].id]
        else
            entity_url = "/player#player"
        end
        msg.post(entity_url, "damage", {
            projectile_velocity = projectile_velocity
        })
        audio.play_sound("hit-person")
    end
end

function M.check_projectile_ground(projectile)
    query_result, result_count = M.query(projectile.aabb_id)
    if query_result and result_count > 0 then
        projectile.lifetime = 0
    end
end

function M.destroy(aabb_id)
    daabbcc.remove(M.group, aabb_id)
end

return M
