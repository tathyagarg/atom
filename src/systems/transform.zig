const std = @import("std");
const math = @import("../core/math/math.zig");
const float = @import("../core/constants.zig").FLOAT;

const Vec3 = math.Vec3;
const Vec3f = Vec3(float);

pub const Bounds = struct {
    minimum: Vec3f,
    maximum: Vec3f,
};

pub const SinglePointHandler = struct {
    point: *Vec3f,
    direction: *Vec3f = @constCast(&Vec3f.zero()),
    is_static: bool = false,
};

pub const MultiPointHandler = struct {
    points: [*]Vec3f,
    point_count: usize,
    is_static: bool = false,

    const Self = @This();

    pub fn bounding_box(self: Self) Bounds {
        var minimum = Vec3f.infinity();
        var maximum = Vec3f.infinity().negate();

        for (self.points) |p| {
            minimum.x = @min(p.x, minimum.x);
            minimum.y = @min(p.y, minimum.y);
            minimum.z = @min(p.z, minimum.z);

            maximum.x = @max(p.x, maximum.x);
            maximum.y = @max(p.y, maximum.y);
            maximum.z = @max(p.z, maximum.z);
        }

        return Bounds{ .minimum = minimum, .maximum = maximum };
    }
};

pub const PositionHandler = union(enum) {
    single: SinglePointHandler,
    multi: MultiPointHandler,

    const Self = @This();

    pub fn translate(self: *const Self, dxyz: Vec3f) void {
        switch (self.*) {
            .single => |s| {
                s.point.* = s.point.add(dxyz);
            },
            .multi => |m| {
                for (0..m.point_count) |i| {
                    m.points[i] = m.points[i].add(dxyz);
                }
            },
        }
    }

    pub fn rotate(self: *const Self, amount: Vec3f) void {
        _ = .{amount};
        switch (self.*) {
            .single => |s| {
                s.direction.* = amount;
            },
            .multi => {
                unreachable;
            }, // TODO: IMPLEMENT THIS
        }
    }

    pub fn get_direction(self: *const Self) *Vec3f {
        return switch (self.*) {
            .single => |s| s.direction,
            .multi => unreachable, // TODO: IMPLEMENT THIS
        };
    }
};
