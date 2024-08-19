const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

pub const E = f64;

pub const Images = @import("images.zig");

pub const Vectors = @import("vectors.zig");
pub const Vec3 = Vectors.Vec3;
pub const P3 = Vectors.P3;

pub const Colors = @import("colors.zig");
pub const Color = Colors.Color;

pub const Rays = @import("rays.zig");
pub const Ray = Rays.Ray;

pub const Sphere = @import("sphere.zig");

pub const Interval = @import("interval.zig");

pub const Hittable = @import("hittable.zig").Hittable;
pub const HittableList = @import("hittable_list.zig");
pub const Collision = Hittable.Collision;

pub const Camera = @import("camera.zig");

pub const inf: E = std.math.inf(E);
pub const pi: E = std.math.pi;

pub inline fn degToRad(degrees: E) E {
    return degrees * pi / 180.0;
}

test {
    testing.refAllDecls(@import("vectors.zig"));
    testing.refAllDecls(@import("colors.zig"));
    testing.refAllDecls(@import("rays.zig"));
    testing.refAllDecls(@import("interval.zig"));
}
