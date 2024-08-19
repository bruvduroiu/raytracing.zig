const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vectors = root.Vectors;
const P3 = Vectors.P3;
const Vec3 = Vectors.Vec3;

pub const Ray = struct {
    const Self = @This();
    const E = P3.Elem;
    orig: P3,
    dir: Vec3,

    pub fn init(origin: P3.V, direction: Vec3.V) Self {
        return .{
            .orig = P3{ .vec = origin },
            .dir = Vec3{ .vec = direction },
        };
    }

    pub fn at(self: Self, t: E) Vec3 {
        return self.orig.add(self.dir.mulScalar(t));
    }

    test at {
        {
            const ray = Ray.init(
                .{ 1, 0, 1 },
                .{ 0, 1, 0 },
            );
            const pos = ray.at(1);
            const expected = .{ 1, 1, 1 };

            try testing.expectEqualDeep(expected, pos);
        }

        {
            const ray = Ray.init(.{ 1, 0, 1 }, .{ -1, -1, 0 });
            const pos = ray.at(1);
            const expected = .{ 0, -1, 1 };

            try testing.expectEqualDeep(expected, pos);
        }
    }
};
