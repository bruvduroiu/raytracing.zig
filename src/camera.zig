const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const P3 = root.P3;
const Vec3 = root.Vec3;

pub const Camera = struct {
    const Self = @This();
    const E = P3.Elem;

    center: P3,
    focal_length: f64,

    pub fn init(center: P3.V, focal_length: f64) Self {
        return .{
            .center = P3{ .vec = center },
            .focal_length = focal_length,
        };
    }
};
