const std = @import("std");

const root = @import("root.zig");
const E = root.E;
const P3 = root.P3;
const Vec3 = root.Vec3;
const Sphere = root.Sphere;
const Ray = root.Ray;
const Interval = root.Interval;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub fn initSphere(center: [3]E, radius: E) Self {
        return .{ .sphere = Sphere.init(center, radius) };
    }

    pub fn deinit(self: Self) void {
        switch (self) {
            inline else => |hittable| hittable.deinit(),
        }
    }

    pub const Collision = struct {
        const Inner = @This();
        pub const Face = enum { front, back };
        t: E,
        p: P3,
        normal: Vec3,
        face: Face,
    };

    pub fn collisionAt(self: Self, interval: Interval, ray: *const Ray) ?Collision {
        switch (self) {
            inline else => |hittable| return hittable.collisionAt(interval, ray),
        }
    }
};
