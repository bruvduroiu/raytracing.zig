const std = @import("std");
const print = std.debug.print;

const root = @import("root.zig");
const Vectors = root.Vectors;
const Rays = root.Rays;
const Colors = root.Colors;
const Color = Colors.Color;
const Ray = Rays.Ray;
const P3 = Vectors.P3;
const Vec3 = Vectors.Vec3;

fn rayColor(r: Ray) Color {
    const unit_direction: Vec3 = r.dir.normed();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).mulScalar(1.0 - a).add(Color.init(0.5, 0.7, 1.0).mulScalar(a));
}

pub fn imagePPM(
    writer: anytype,
    width: usize,
    aspect_ratio: f64,
    viewport_height: f64,
    comptime log: bool,
) !void {
    // Image constants
    const width_f: f64 = @floatFromInt(width);
    const max_color = 255;

    const height: usize = blk: {
        const h: usize = @intFromFloat(width_f / aspect_ratio);
        break :blk if (h >= 1) h else 1;
    };
    const height_f: f64 = @floatFromInt(height);

    // The image's real aspect ratio might not match ideal aspect ratio,
    // so we use the real value for the viewport aspect ratio.
    const viewport_width: f64 = viewport_height * (width_f / height_f);

    const focal_length = 1.0;
    const camera_center = P3.init(0, 0, 0);

    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    const pixel_delta_u = viewport_u.divScalar(width_f);
    const pixel_delta_v = viewport_v.divScalar(height_f);

    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.divScalar(2)).sub(viewport_v.divScalar(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));

    // Render image

    // We render the image in the
    // [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format.
    try writer.print("P3\n{d} {d}\n{d}\n", .{ width, height, max_color });

    for (0..height) |j| {
        if (log) print("\rScanlines remaining: {d: >5}", .{height - j});
        for (0..width) |i| {
            const i_f: f64 = @floatFromInt(i);
            const j_f: f64 = @floatFromInt(j);
            const pixel_center = pixel00_loc.add(pixel_delta_u.mulScalar(i_f)).add(pixel_delta_v.mulScalar(j_f));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.init(camera_center.vec, ray_direction.vec);
            const color = rayColor(r);

            try Colors.writeColor(writer, color);
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}
