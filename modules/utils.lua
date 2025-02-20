M = {}

function M.sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

function M.random_float(min, max)
    return min + math.random() * (max - min)
end


function M.clamp(value, max_value)
    local min_value = -max_value
    if value > max_value then
        return max_value
    elseif value < min_value then
        return min_value
    end
    return value
end

function M.get_key_by_value(tbl, value)
    for key, val in pairs(tbl) do
        if type(val) == "table" then
            for _, v in ipairs(val) do
                if v == value then
                    return key
                end
            end
        else
            if val == value then
                return key
            end
        end
    end
    return nil
end


function M.is_table_empty(tbl)
    return next(tbl) == nil
end

function M.extract_key_from_hash_string(input_string)
    return input_string:match("%[(.-)%]")
end

local camera_url = msg.url('game:/camera#camera')

function M.is_box_on_screen(self, position, width, height)

    local projection = camera.get_projection(camera_url)
    local view = camera.get_view(camera_url)
    local view_projection = projection * view

    local half_width = width / 2
    local half_height = height / 2
    local corners = {
        vmath.vector4(position.x - half_width, position.y - half_height, position.z or 0, 1),
        vmath.vector4(position.x + half_width, position.y - half_height, position.z or 0, 1),
        vmath.vector4(position.x - half_width, position.y + half_height, position.z or 0, 1),
        vmath.vector4(position.x + half_width, position.y + half_height, position.z or 0, 1),
    }

    local on_screen = false
    local result = {above = false, below = false, left = false, right = false}

    for _, corner in ipairs(corners) do
        local ndc_position = view_projection * corner
        ndc_position.x = ndc_position.x / ndc_position.w
        ndc_position.y = ndc_position.y / ndc_position.w
        ndc_position.z = ndc_position.z / ndc_position.w

        local corner_on_screen = ndc_position.x >= -1 and ndc_position.x <= 1 and
                                 ndc_position.y >= -1 and ndc_position.y <= 1 and
                                 ndc_position.z >= 0 and ndc_position.z <= 1
        on_screen = on_screen or corner_on_screen

        result.above = result.above or ndc_position.y > 1
        result.below = result.below or ndc_position.y < -1
        result.left = result.left or ndc_position.x < -1
        result.right = result.right or ndc_position.x > 1
    end

    result.on_screen = on_screen

    return result
end

return M