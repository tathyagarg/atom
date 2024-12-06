const math = @import("../../core/math/all.zig");
const float = @import("../../core/constants.zig").FLOAT;

const Vec3 = math.Vec3;
const Vec2 = math.Vec2;

const Vec3f = math.Vec3(float);
const Vec2f = math.Vec2(float);

const Ray = @import("../ray.zig").Ray;
const ArrayList = @import("std").ArrayList;
const Material = @import("../material.zig").Material;

const solve_quadratic = math.solve_quadratic;

pub const Sphere = struct {
    center: Vec3f,
    radius: float,
    radius_sqr: float = undefined,
    material: Material,

    const Self = @This();

    pub fn init(c: Vec3f, r: float, material: Material) Self {
        return Self{
            .center = c,
            .radius = r,
            .radius_sqr = r * r,
            .material = material,
        };
    }

    pub fn intersects(self: Self, ray: Ray, t: *float) bool {
        const L: Vec3f = ray.origin.subtract(self.center);
        const a: float = ray.direction.dot(ray.direction);
        const b: float = 2 * ray.direction.dot(L);
        const c: float = L.dot(L) - self.radius_sqr;

        var t0: float = undefined;
        var t1: float = undefined;

        if (!solve_quadratic(a, b, c, &t0, &t1)) return false;

        if (t0 < 0) t0 = t1;
        if (t0 < 0) return false;

        t.* = t0;
        return true;
    }

    pub fn get_surface_props(
        self: Self,
        P: *const Vec3f,
        I: *const Vec3f,
        index: usize,
        uv: *Vec2f,
        normal: *Vec3f,
        st: *Vec2f,
    ) void {
        normal.* = (P.subtract(self.center)).normalize();
        _ = .{ I, index, uv, st };
    }
};