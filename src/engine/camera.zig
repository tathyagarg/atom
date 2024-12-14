const std = @import("std");
const math = @import("../core/math/math.zig");
const float = @import("../core/constants.zig").FLOAT;

const Vec3 = math.Vec3;
const Vec3f = Vec3(float);

pub const Camera = struct {
    position: *Vec3f,
    direction: *Vec3f,

    const Self = @This();

    pub fn get_direction(self: Self, x: float, y: float) Vec3f {
        // Facing -z (0 0 -1):  x  y -1
        // Facing z  (0 0 1) :  x  y  1
        // Facing -x (-1 0 0): -1  y  x
        // Facing x  (1 0 0) :  1  y  x
        // Facing -y (0 -1 0):  x -1  y
        // Facing y  (0 1 0) :  x  1  y
        _ = .{ self, x, y };

        // "How did you come to these formulas?" you may ask
        // I have no fucking clue
        // I just typed it and it worked
        // Update: no it fucking didnt
        return Vec3f.init(
            -1, // This is such fucking bullshit
            y, // This is such fucking bullshit
            x, // This is such fucking bullshit
        );
    }
};
