local M = {}

function M.handle(self, normal, distance, callback)
    distance = distance * vmath.length(normal)
    if distance > 0 then
        local proj = vmath.project(self.correction, normal * distance)
        if proj < 1 then
            local comp = (distance - proj * distance) * normal
            go.set_position(go.get_position() + comp)
            self.correction = self.correction + comp
        end
    end

    callback(self, normal)
end

return M