const std = @import("std");

const root = @import("root.zig");
const Vec3 = root.Vec3;
const P3 = root.P3;
const E = root.E;
const Ray = root.Ray;
const Interval = root.Interval;
const Collision = root.Collision;

const Self = @This();
center: Vec3,
radius: E,

pub fn init(center: [3]E, radius: E) Self {
    std.debug.assert(radius >= 0);
    return .{
        .center = Vec3.fromArray(center),
        .radius = radius,
    };
}

pub fn deinit(_: Self) void {}

pub fn hit(self: Self, ray: *const Ray) E {
    const oc: Vec3 = self.center.sub(ray.orig);
    const a: E = ray.dir.lengthSquared();
    const h: E = ray.dir.dot(oc);
    const c: E = oc.lengthSquared() - std.math.pow(E, self.radius, 2);
    const discr: E = std.math.pow(E, h, 2) - a * c;

    if (discr < 0) {
        return -1.0;
    } else {
        return (h - @sqrt(discr)) / a;
    }
}

pub fn collisionAt(self: Self, interval: Interval, ray: *const Ray) ?Collision {
    const oc: Vec3 = self.center.sub(ray.orig);
    const a: E = ray.dir.lengthSquared();
    const h: E = ray.dir.dot(oc);
    const c: E = oc.lengthSquared() - std.math.pow(E, self.radius, 2);
    const d: E = std.math.pow(E, h, 2) - a * c;
    if (d < 0) return null;

    const sqrt = @sqrt(d);
    const first = (h - sqrt) / a;
    const second = (h + sqrt) / a;

    const t = if (interval.surrounds(first)) first else second;
    if (!interval.surrounds(t)) return null;
    var normal = self.normalAt(ray.at(t));
    var face = Collision.Face.front;
    if (ray.dir.dot(normal) > 0) {
        normal = normal.mulScalar(-1);
        face = .back;
    }
    return Collision{
        .t = t,
        .p = ray.at(t),
        .normal = normal,
        .face = face,
    };
}

fn normalAt(self: Self, point: P3) Vec3 {
    return self.center.to(point).divScalar(self.radius);
}
