#include <stdio.h>
#include "clipper_offset.h"

using namespace clipperlib;

#ifdef _WIN32
    #define export extern "C" __declspec(dllexport)
#else
    #define export extern "C" __attribute__((visibility("default")))
#endif

std::string err_m;

export const char *err_msg() {
    return err_m.c_str();
}

export Path *path_new() {
    return new Path();
}

export void path_free(Path *path) {
    delete path;
}

export Point64 *path_get(Path *path, int i) {
    return &((*path)[i]);
}

export bool path_add(Path *path, int64_t x, int64_t y) {
    try
    {
        path->push_back(Point64(x, y));
        return true;
    }
    catch (...)
    {
        return false;
    }
}

export int path_size(Path *path) {
    return path->size();
}

export Paths *paths_new() {
    return new Paths();
}

export void paths_free(Paths *paths) {
    delete paths;
}

export Path *paths_get(Paths *paths, int i) {
    return &((*paths)[i]);
}

export bool paths_add(Paths *paths, Path *path) {
    try
    {
        paths->push_back(*path);
        return true;
    }
    catch (...)
    {
        return false;
    }
}

export int paths_size(Paths *paths) {
    return paths->size();
}

export ClipperOffset *offset_new(double mt, double at) {
    return new ClipperOffset(mt, at);
}

export void offset_free(ClipperOffset *off)
{
    delete off;
}

export Paths *offset_add_path(ClipperOffset *off, Path *path, double delta, int jt, int et) {
    Paths *solution = new Paths();
    try
    {
        off->AddPath(*path, JoinType(jt), EndType(et));
        off->Execute(*solution, delta);
    }
    catch (ClipperException &e)
    {
        err_m = e.what();
        delete solution;
        return NULL;
    }
    return solution;
}

export Paths *offset_add_paths(ClipperOffset *off, Paths *path, double delta, int jt, int et) {
    Paths *solution = new Paths();
    try
    {
        off->AddPaths(*path, JoinType(jt), EndType(et));
        off->Execute(*solution, delta);
    }
    catch (ClipperException &e)
    {
        err_m = e.what();
        delete solution;
        return NULL;
    }
    return solution;
}

export void offset_clear(ClipperOffset *off) {
    off->Clear();
}

export Clipper *clipper_new(Clipper *cpp) {
    return new Clipper();
}

export void clipper_free(Clipper *cpp) {
    delete cpp;
}

export void clipper_clear(Clipper *cpp) {
    cpp->Clear();
}

export bool clipper_add_path(Clipper *cpp, Path *path, int pt, bool is_open) {
    try
    {
        cpp->AddPath(*path, PathType(pt), is_open);
        return true;
    }
    catch (ClipperException &e)
    {
        err_m = e.what();
        return false;
    }
}

export bool clipper_add_paths(Clipper *cpp, Paths *path, int pt, bool is_open) {
    try
    {
        cpp->AddPaths(*path, PathType(pt), is_open);
        return true;
    }
    catch (ClipperException &e)
    {
        err_m = e.what();
        return false;
    }
}

export Paths *clipper_execute(Clipper *cpp, int ct, int fr) {
    Paths *solution = new Paths();
    try
    {
        cpp->Execute(ClipType(ct), *solution, FillRule(fr));
    }
    catch (ClipperException &e)
    {
        delete solution;
        err_m = e.what();
        return NULL;
    }
    return solution;
}