local poly = require "clipper"

local create_path = function(path)
    local pts = poly.Path()
    for k = 1, #path, 2 do
        pts:add(path[k], path[k + 1])
    end
    return pts
end

local create_paths = function(paths)
    local points = poly.Paths()
    points:add(create_path(paths))
    return points
end

local get_solution = function(paths)
    local get_path_points
    get_path_points = function(path)
        local result = {}
        for k = 1, path:size() do
            local point = path:get(k)
            result[k] = {
                x = tonumber(point.x),
                y = tonumber(point.y)
            }
        end
        return result
    end
    local result = {}
    for k = 1, paths:size() do
        result[k] = get_path_points(paths:get(k))
    end
    return result
end

local simplify = function(paths)
    local points = poly.Paths()
    points:add(create_path(paths))
    points = points:simplify()
    return get_solution(points)
end

local clean = function(paths)
    local points = poly.Paths()
    points:add(create_path(paths))
    points = points:clean_polygon()
    return get_solution(points)
end

local clipper = function(points_subj, points_clip, fill_types, clip_type)
    fill_types = fill_types or "even_odd"
    clip_type = clip_type or "intersection"

    local ft_subj, ft_clip = fill_types[1], fill_types[2]
    if type(fill_types) ~= "table" then
        ft_subj, ft_clip = fill_types, fill_types
    end

    local subj = create_paths(points_subj)
    local clip = create_paths(points_clip)
    local pc = poly.Clipper()
    pc:add_paths(subj, "subject")
    pc:add_paths(clip, "clip")
    local final = pc:execute(clip_type, ft_subj, ft_clip)

    return get_solution(final)
end

local offset = function(points, size, join_type, end_type, miter_limit, arc_toleranc)
    join_type, end_type = join_type or "round", end_type or "closed_polygon"
    miter_limit, arc_toleranc = miter_limit or 3, arc_toleranc or 0.25

    local po = poly.ClipperOffset(miter_limit, arc_toleranc)
    local pp = create_paths(points)
    local final = po:offset_paths(pp, size, join_type, end_type)

    return get_solution(final)
end

-- EXAMPLES CLIPPER
local subj_points = {0, 0, 25, -25, 93, -25, 107, 6, 94, 32, 29, 53, 4, 38, -14, 17, -1, -7, 0, 0}
local clip_points = {16, 22, 1, -26, 65, 1, 80, 52, 16, 22}

local clipping = clipper(subj_points, clip_points) -- even_odd and intersection
-- local clipping2 = clipper(subj_points, clip_points, "even_odd", "union")
-- local clipping3 = clipper(subj_points, clip_points, "even_odd", "difference")
-- local clipping4 = clipper(subj_points, clip_points, "even_odd", "xor")

for k, v in ipairs(clipping) do
    print("== CLIPPING")
    for _, p in pairs(v) do
        print("X: " .. p.x, "Y: " .. p.y)
    end
end

-- EXAMPLE OFFSET
local offsetting = offset(subj_points, 5)

for k, v in ipairs(offsetting) do
    print("\n\n\n== OFFSETTING")
    for _, p in pairs(v) do
        print("X: " .. p.x, "Y: " .. p.y)
    end
end

-- EXAMPLE SIMPLIFY
local points_sm = {0, 0, 4, 54, 65, 7, 0, 0, 33, 50, 40, -11}
local simple = simplify(points_sm)

for _, v in ipairs(simple) do
    print("\n\n\n== SIMPLIFYING")
    for _, p in pairs(v) do
        print("X: " .. p.x, "Y: " .. p.y)
    end
end
