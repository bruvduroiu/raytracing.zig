const std = @import("std");
const testing = std.testing;
const Random = std.rand.Random;

const root = @import("root.zig");

pub const Vec3 = Vector3(f64);
pub const P3 = Point3(f64);

const Point3 = Vector3;
pub fn Vector3(comptime E: type) type {
    return struct {
        const Self = @This();
        pub const Elem = E;
        pub const V = @Vector(3, E);
        vec: V,

        pub fn init(vx: E, vy: E, vz: E) Self {
            return .{
                .vec = V{ vx, vy, vz },
            };
        }

        pub fn fromArray(xyz: [3]E) Self {
            return .{
                .vec = V{ xyz[0], xyz[1], xyz[2] },
            };
        }

        pub fn to(self: Self, destination: Self) Vec3 {
            return destination.sub(self);
        }

        pub inline fn x(self: Self) E {
            return self.vec[0];
        }

        pub inline fn y(self: Self) E {
            return self.vec[1];
        }

        pub inline fn z(self: Self) E {
            return self.vec[2];
        }

        pub inline fn add(self: Self, other: Self) Self {
            return .{ .vec = self.vec + other.vec };
        }

        pub inline fn sub(self: Self, other: Self) Self {
            return .{ .vec = self.vec - other.vec };
        }

        pub inline fn mul(self: Self, other: Self) Self {
            return .{ .vec = self.vec * other.vec };
        }

        pub inline fn div(self: Self, other: Self) Self {
            return .{ .vec = self.vec / other.vec };
        }

        pub inline fn addScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec + @as(V, @splat(scalar)) };
        }

        pub inline fn subScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec - @as(V, @splat(scalar)) };
        }

        pub inline fn mulScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec * @as(V, @splat(scalar)) };
        }

        pub inline fn divScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec / @as(V, @splat(scalar)) };
        }

        pub fn lengthSquared(self: Self) E {
            return @reduce(.Add, self.vec * self.vec);
        }

        pub fn length(self: Self) E {
            return @sqrt(lengthSquared(self));
        }

        pub fn normed(self: Self) Self {
            return self.divScalar(self.length());
        }

        pub fn dot(u: Self, v: Self) E {
            return @reduce(.Add, u.vec * v.vec);
        }

        pub fn cross(u: Self, v: Self) Self {
            const uv, const vv = .{ u.vec, v.vec };
            return .{ .vec = .{
                uv[1] * vv[2] - uv[2] * vv[1],
                uv[2] * vv[0] - uv[0] * vv[2],
                uv[0] * vv[1] - uv[1] * vv[0],
            } };
        }

        pub fn makeUnitVector(self: Self) Self {
            const inv_n = 1.0 / self.length();
            return Self{
                .x = self.x() * inv_n,
                .y = self.y() * inv_n,
                .z = self.z() * inv_n,
            };
        }

        pub fn randomUnitVector(r: *const Random) Self {
            return while (true) {
                const p = Self.init(r.float(E), r.float(E), r.float(E));
                const lensq = p.lengthSquared();
                if (lensq < 1.0) {
                    break p.divScalar(lensq);
                }
            } else Vec3.init(0, 0, 0);
        }

        pub fn random(r: *const Random, min: E, max: E) Self {
            return Self.init(root.boundedRandom(r, min, max), root.boundedRandom(r, min, max), root.boundedRandom(r, min, max));
        }

        pub fn normalRandom(r: *const Random) Self {
            return Self.init(root.boundedRandom(r, 0.0, 1.0), root.boundedRandom(r, 0.0, 1.0), root.boundedRandom(r, 0.0, 1.0));
        }

        test x {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(1.0, vec.x(), 0.01);
        }

        test y {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(2.0, vec.y(), 0.01);
        }

        test z {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(3.0, vec.z(), 0.01);
        }

        test lengthSquared {
            const vec = Vec3.init(3, 4, 0);
            const len = vec.lengthSquared();

            try testing.expectApproxEqAbs(25.0, len, 0.01);
        }

        test length {
            const vec = Vec3.init(3, 4, 0);
            const len = vec.length();

            try testing.expectApproxEqAbs(5.0, len, 0.01);
        }

        test normed {
            const vec = Vec3.init(112, 90, -1);
            const norm = vec.normed();
            const len = norm.length();

            try testing.expectApproxEqAbs(1.0, len, 0.01);
        }

        test dot {
            const left = Vec3.init(1, 2, 3);
            const right = Vec3.init(6, 5, 4);
            const dotted = left.dot(right);

            try testing.expectApproxEqAbs(28, dotted, 0.01);
        }

        test cross {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(6, 5, 4);
            const crossed = u.cross(v);

            try testing.expectApproxEqAbs(-7, crossed.x(), 0.01);
            try testing.expectApproxEqAbs(14, crossed.y(), 0.01);
            try testing.expectApproxEqAbs(-7, crossed.z(), 0.01);
        }
    };
}
