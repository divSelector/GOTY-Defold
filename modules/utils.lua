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


return M