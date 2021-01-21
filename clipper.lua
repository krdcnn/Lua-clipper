local ffi = require("ffi")
local C_6 = ffi.load("clipper")

ffi.cdef([[

    typedef struct __zf_int_point { int64_t x, y; } zf_int_point;
    typedef struct __zf_int_rect { int64_t left; int64_t top; int64_t right; int64_t bottom; } zf_int_rect;
    typedef signed long long cInt;
    typedef struct __zf_path zf_path;
    typedef struct __zf_paths zf_paths;
    typedef struct __zf_offset zf_offset;
    typedef struct __zf_clipper zf_clipper;

    const char* zf_err_msg();
    zf_path* zf_path_new();
    void zf_path_free(zf_path *self);
    zf_int_point* zf_path_get(zf_path *self, int i);
    bool zf_path_add(zf_path *self, cInt x, cInt y);
    int zf_path_size(zf_path *self);
    double zf_path_area(const zf_path *self);
    bool zf_path_orientation(const zf_path *self);
    void zf_path_reverse(zf_path *self);
    int zf_path_point_in_polygon(zf_path *self,cInt x, cInt y);
    zf_paths* zf_path_simplify(zf_path *self,int fillType);
    zf_path* zf_path_clean_polygon(const zf_path *in, double distance);

    zf_paths* zf_paths_new();
    void zf_paths_free(zf_paths *self);
    zf_path* zf_paths_get(zf_paths *self, int i);
    bool zf_paths_add(zf_paths *self, zf_path *path);
    zf_paths* zf_paths_simplify(zf_paths *self, int fillType);
    zf_paths* zf_paths_clean_polygon(zf_paths *self, double distance);
    int zf_paths_size(zf_paths *self);

    zf_offset* zf_offset_new(double miterLimit, double roundPrecision);
    void zf_offset_free(zf_offset *self);
    zf_paths* zf_offset_path(zf_offset *self, zf_path *subj, double delta, int jointType, int endType);
    zf_paths* zf_offset_paths(zf_offset *self, zf_paths *subj, double delta, int jointType, int endType);
    void zf_offset_clear(zf_offset *self);

    zf_clipper* zf_clipper_new();
    void zf_clipper_free(zf_clipper *CLP);
    void zf_clipper_clear(zf_clipper *CLP);
    bool zf_clipper_add_path(zf_clipper *CLP,zf_path *path, int pt, bool closed,const char *err);
    bool zf_clipper_add_paths(zf_clipper *CLP,zf_paths *paths, int pt, bool closed,const char *err);
    void zf_clipper_reverse_solution(zf_clipper *CLP, bool value);
    void zf_clipper_preserve_collinear(zf_clipper *CLP, bool value);
    void zf_clipper_strictly_simple(zf_clipper *CLP, bool value);
    zf_paths* zf_clipper_execute(zf_clipper *CLP,int clipType,int subjFillType,int clipFillType);
    zf_int_rect zf_clipper_get_bounds(zf_clipper *CLP);

]])

local Path, Paths, ClipperOffset, Clipper = {}, {}, {}, {}

local ClipType = {
    intersection = 0,
    union = 1,
    difference = 2,
    xor = 3
}

local JoinType = {
    square = 0,
    round = 1,
    miter = 2
}

local EndType = {
    closed_polygon = 0,
    closed_line = 1,
    open_butt = 2,
    open_square = 3,
    open_round = 4
}

local InitOptions = {
    reverse_solution = 1,
    strictly_simple = 2,
    preserve_collinear = 4
}

local PolyType = {
    subject = 0,
    clip = 1
}

local PolyFillType = {
    none = 0,
    even_odd = 1,
    non_zero = 2,
    positive = 3,
    negative = 4
}

Path.new = function()
    return ffi.gc(C_6.zf_path_new(), C_6.zf_path_free)
end

Path.add = function(self, x, y)
    return C_6.zf_path_add(self, x, y)
end

Path.get = function(self, i)
    return C_6.zf_path_get(self, i - 1)
end

Path.size = function(self)
    return C_6.zf_path_size(self)
end

Path.area = function(self)
    return C_6.zf_path_area(self)
end

Path.reverse = function(self)
    return C_6.zf_path_reverse(self)
end

Path.orientation = function(self)
    return C_6.zf_path_orientation(self)
end

Path.contains = function(self, x, y)
    return C_6.zf_path_point_in_polygon(self, x, y)
end

Path.simplify = function(self, fillType)
    fillType = fillType or "non_zero"
    fillType = assert(PolyFillType[fillType], "unknown fill type")
    return C_6.zf_path_simplify(self, fillType)
end

Path.clean_polygon = function(self, distance)
    distance = distance or 1.415
    return C_6.zf_path_clean_polygon(self, distance)
end

Paths.new = function()
    return ffi.gc(C_6.zf_paths_new(), C_6.zf_paths_free)
end

Paths.add = function(self, path)
    return C_6.zf_paths_add(self, path)
end

Paths.get = function(self, i)
    return C_6.zf_paths_get(self, i - 1)
end

Paths.simplify = function(self, fillType)
    fillType = fillType or "even_odd"
    fillType = assert(PolyFillType[fillType], "unknown fill type")
    return C_6.zf_paths_simplify(self, fillType)
end

Paths.clean_polygon = function(self, distance)
    distance = distance or 1.415
    return C_6.zf_paths_clean_polygon(self, distance)
end

Paths.size = function(self)
    return C_6.zf_paths_size(self)
end

ClipperOffset.new = function(miter_limite, arc_tolerance)
    local co = C_6.zf_offset_new(miter_limite or 2, arc_tolerance or 0.25)
    return ffi.gc(co, C_6.zf_offset_free)
end

ClipperOffset.offset_path = function(self, path, delta, jt, et)
    jt, et = jt or "square", et or "open_butt"
    assert(JoinType[jt])
    assert(EndType[et])
    local out = C_6.zf_offset_path(self, path, delta, JoinType[jt], EndType[et])
    if out == nil then
        error(ffi.string(C_6.zf_err_msg()))
    end
    return out
end

ClipperOffset.offset_paths = function(self, paths, delta, jt, et)
    jt, et = jt or "square", et or "open_butt"
    assert(JoinType[jt])
    assert(EndType[et])
    local out = C_6.zf_offset_paths(self, paths, delta, JoinType[jt], EndType[et])
    if out == nil then
        error(ffi.string(C_6.zf_err_msg()))
    end
    return out
end

ClipperOffset.clear = function(self)
    return C_6.zf_offset_clear(self)
end

Clipper.new = function(...)
    for _, opt in ipairs({...}) do
        assert(InitOptions[opt])
        local _exp_0 = opt
        if "strictly_simple" == _exp_0 then
            C_6.zf_clipper_strictly_simple(true)
        elseif "reverse_solution" == _exp_0 then
            C_6.zf_clipper_reverse_solution(true)
        else
            C_6.zf_clipper_preserve_collinear(true)
        end
    end
    return ffi.gc(C_6.zf_clipper_new(), C_6.zf_clipper_free)
end

Clipper.clear = function(self)
    return C_6.zf_clipper_clear(self)
end

Clipper.add_path = function(self, path, pt, closed)
    assert(path, "path is nil")
    assert(PolyType[pt], "unknown polygon type")
    if closed == nil then
        closed = true
    end
    return C_6.zf_clipper_add_path(self, path, PolyType[pt], closed, err)
end

Clipper.add_paths = function(self, paths, pt, closed)
    assert(paths, "paths is nil")
    assert(PolyType[pt], "unknown polygon type")
    if closed == nil then
        closed = true
    end
    if not (C_6.zf_clipper_add_paths(self, paths, PolyType[pt], closed, err)) then
        return error(ffi.string(C_6.zf_err_msg()))
    end
end

Clipper.execute = function(self, clipType, subjFillType, clipFillType)
    subjFillType = subjFillType or "even_odd"
    clipFillType = clipFillType or "even_odd"
    clipType = assert(ClipType[clipType], "unknown clip type")
    subjFillType = assert(PolyFillType[subjFillType], "unknown fill type")
    clipFillType = assert(PolyFillType[clipFillType], "unknown fill type")
    local out = C_6.zf_clipper_execute(self, clipType, subjFillType, clipFillType)
    if out == nil then
        error(ffi.string(C_6.zf_err_msg()))
    end
    return out
end

Clipper.get_bounds = function(self)
    local r = C_6.zf_clipper_get_bounds(self)
    return tonumber(r.left), tonumber(r.top), tonumber(r.right), tonumber(r.bottom)
end

ffi.metatype("zf_path", {
    __index = Path
})
ffi.metatype("zf_paths", {
    __index = Paths
})
ffi.metatype("zf_offset", {
    __index = ClipperOffset
})
ffi.metatype("zf_clipper", {
    __index = Clipper
})

return {
    Path = Path.new,
    Paths = Paths.new,
    ClipperOffset = ClipperOffset.new,
    Clipper = Clipper.new
}