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
        if val == value then
            return key
        end
    end
    return nil
end

return M