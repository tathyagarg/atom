const std = @import("std");
const z3d = @import("z3d");
const engine = z3d.engine;
const graphics = z3d.graphics;
const math = z3d.math;
const physics = z3d.physics;

const Vec3 = math.Vec3(f32);
const Vec2 = math.Vec2(f32);
const Scene = engine.Scene;
const objects = graphics.objects;
const Light = graphics.Light;

const allocator = std.testing.allocator;

test "physics engine" {
    var sphere_mat = graphics.material.Material{
        .diffuse_color = Vec3.init(0.1, 0.2, 0.9),
    };

    var sphere_pos = Vec3.init(-1, -1, -10);
    const sphere = objects.Object{
        .sphere = objects.Sphere.init(
            &sphere_pos,
            3,
            &sphere_mat,
        ),
    };

    var vertices_data = [_]Vec3{
        Vec3.init(-5, -3, -6),
        Vec3.init(5, -3, -6),
        Vec3.init(5, -3, -16),
        Vec3.init(-5, -3, -16),
    };
    var vertices: [*]Vec3 = &vertices_data;

    const vertex_indices = [6]usize{ 0, 1, 3, 1, 2, 3 };
    const textures = [4]Vec2{
        Vec2.init(0, 0),
        Vec2.init(1, 0),
        Vec2.init(1, 1),
        Vec2.init(0, 1),
    };

    var mesh_mat = graphics.material.Material{
        .material_type = graphics.material.MaterialType.DIFFUSE_AND_GLOSSY,
    };

    const mesh = objects.Object{
        .mesh_triangle = objects.MeshTriangle.init(
            &vertices,
            4,
            &vertex_indices,
            2,
            &textures,
            &mesh_mat,
            null,
        ),
    };
    // sphere.add_physics(&physics_engine);

    var scene_objects = std.ArrayList(objects.Object).init(allocator);
    defer scene_objects.deinit();

    try scene_objects.append(sphere);
    try scene_objects.append(mesh);

    try sphere.sphere.position.translate(Vec3.init(1, 2, 0));

    const light = Light{
        .position = Vec3.init(-20, 70, 20),
        .intensity = Vec3.init(0.8, 0.8, 0.8),
    };

    var lights = std.ArrayList(Light).init(allocator);
    defer lights.deinit();

    try lights.append(light);

    const scene = Scene.init(&scene_objects, &lights, .{});
    var frame_buffer = try allocator.alloc(Vec3, @sizeOf(Vec3) * 400 * 400);
    defer allocator.free(frame_buffer);

    scene.render(&frame_buffer);

    var outputs = try std.fs.cwd().openDir("tests/outputs", .{});
    defer outputs.close();

    const ppm = try outputs.createFile("physics.ppm", .{});
    defer ppm.close();

    _ = try ppm.write("P6\n");

    const line_2 = try std.fmt.allocPrint(
        allocator,
        "{d} {d}\n255\n",
        .{ 400, 400 },
    );
    defer allocator.free(line_2);

    _ = try ppm.write(line_2);
    for (frame_buffer) |pixel| {
        const arr = [3]u8{
            @as(u8, @intFromFloat(@max(0.0, @min(1.0, pixel.x)) * 255)),
            @as(u8, @intFromFloat(@max(0.0, @min(1.0, pixel.y)) * 255)),
            @as(u8, @intFromFloat(@max(0.0, @min(1.0, pixel.z)) * 255)),
        };
        _ = try ppm.write(&arr);
    }
}
