local util = {}

local function vertex_equal(v1, v2, epsilon)
    if #v1 ~= #v2 then return false end

    local dx = v2[1] - v1[1]
    local dy = v2[2] - v1[2]
    local dr = epsilon or 0.001

    return dx^2 + dy^2 < dr^2
end

local function are_vertices_clockwise(v1, v2)
    return v1[2] * v2[1] - v1[1] * v2[2] > 0
end

-- assuming anti-clockwise triangle points
local function triangle_area(a, b, c)
    local v1 = {c[1] - a[1], c[2] - a[2]}
    local v2 = {b[1] - a[1], b[2] - a[2]}
    return (c[2] - a[2]) * (b[1] - a[1]) - (c[1] - a[1]) * (b[2] - a[2])
end


function util.distance_squared(point1, point2)
    return (point2[2] - point1[2]) ^ 2 + (point2[1] - point1[1]) ^ 2
end

function util.circle_contains_point(centre, radius, point)
    return vertex_equal(centre, point, radius)
end

-- assuming anti-clockwise polygon vertices
function util.polygon_contains_point(polygon, point, line_counts_as_inside)
    for i = 1, #polygon, 2 do
        local j = i + 1

        local i2 = i + 2
        local j2 = i + 3

        if i2 > #polygon then 
            i2 = 1
            j2 = 2
        end

        local x1 = polygon[i]  - point[1]
        local y1 = polygon[j]  - point[2]
        local x2 = polygon[i2] - point[1]
        local y2 = polygon[j2] - point[2]

        local a = x2 * y1 - x1 * y2

        if a == 0 and not line_counts_as_inside then 
            return false
        elseif a < 0 then 
            return false
        end
    end

    return true
end

function util.sector_contains_point(centre, start_angle, end_angle, radius, point)
    local relative_centre = { point[1] - centre[1], point[2] - centre[2] }

    local start_vector = {radius * math.cos(start_angle), radius * math.sin(start_angle)}
    local end_vector   = {radius * math.cos(end_angle),   radius * math.sin(end_angle)}

    return (not are_vertices_clockwise(start_vector, relative_centre)) and 
            are_vertices_clockwise(end_vector, relative_centre) and
            util.circle_contains_point(centre, radius, point)
end

return util