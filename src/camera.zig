const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const Random = std.rand.Random;

const root = @import("root.zig");
const E = root.E;
const P3 = root.P3;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Color = root.Color;
const Hittable = root.Hittable;
const HittableList = root.HittableList;
const Interval = root.Interval;
const Colors = root.Colors;

const Self = @This();
width: usize,
height: usize,
camera_center: P3,
pixel00_loc: P3,
pixel_delta_u: Vec3,
pixel_delta_v: Vec3,
samples_per_pixel: E,

pub const Config = struct {
    aspect_ratio: E = 1.0,
    width: usize = 400,
    focal_length: E = 1.0,
    viewport_height: E = 2.0,
    samples_per_pixel: E = 10.0,
};

pub fn init(config: Config) Self {
    const width_f: E = @floatFromInt(config.width);
    const height = @max(@as(usize, @intFromFloat(width_f / config.aspect_ratio)), 1);
    const height_f: E = @floatFromInt(height);

    const viewport_height: E = config.viewport_height;
    const viewport_width: E = viewport_height * (width_f / height_f);

    const focal_length = 1.0;
    const camera_center = P3.init(0, 0, 0);

    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    const pixel_delta_u = viewport_u.divScalar(width_f);
    const pixel_delta_v = viewport_v.divScalar(height_f);

    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.divScalar(2)).sub(viewport_v.divScalar(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));

    return .{
        .width = config.width,
        .height = height,
        .pixel00_loc = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .camera_center = camera_center,
        .samples_per_pixel = config.samples_per_pixel,
    };
}

pub fn getRay(comptime self: Self, i: E, j: E) Ray {
    const offset = sampleSquare() catch Vec3.init(0.0, 0.0, 0.0);
    const pixelSample = self.pixel00_loc.add(self.pixel_delta_u.mulScalar(offset.x() + i)).add(self.pixel_delta_v.mulScalar(offset.y() + j));

    const rayOrigin = self.camera_center;
    const rayDirection = pixelSample.sub(rayOrigin);

    return Ray.init(rayOrigin.vec, rayDirection.vec);
}

fn sampleSquare() !Vec3 {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    return Vec3.init(rand.float(E) - 0.5, rand.float(E) - 0.5, 0);
}

pub fn render(comptime self: Self, world: *const HittableList, writer: anytype, log: bool) !void {
    const max_color = 255;
    try writer.print("P3\n{d} {d}\n{d}\n", .{ self.width, self.height, max_color });

    for (0..self.height) |j| {
        if (log) print("\rScanlines remaining: {d: >5}", .{self.height - j});
        for (0..self.width) |i| {
            const i_f: f64 = @floatFromInt(i);
            const j_f: f64 = @floatFromInt(j);
            var color = Color.init(0, 0, 0);
            for (0..self.samples_per_pixel) |_| {
                const r = self.getRay(i_f, j_f);
                color = color.add(rayColor(&r, world));
            }

            try Colors.writeColor(writer, color.mulScalar(1.0 / self.samples_per_pixel));
            try writer.writeAll(if (i + 1 < self.width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}

fn rayColor(r: *const Ray, world: *const HittableList) Color {
    if (world.hit(Interval.init(0.001, root.inf), r)) |c| {
        return c.normal.add(Color.init(1, 1, 1)).mulScalar(0.5);
    }

    const unit_direction: Vec3 = r.dir.normed();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).mulScalar(1.0 - a).add(Color.init(0.5, 0.7, 1.0).mulScalar(a));
}
