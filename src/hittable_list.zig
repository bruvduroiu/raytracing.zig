const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Hittable = root.Hittable;
const Interval = root.Interval;
const Ray = root.Ray;
const Collision = root.Collision;

const Self = @This();
objects: std.ArrayList(Hittable),

pub fn init(alloc: Allocator) !Self {
    return .{ .objects = std.ArrayList(Hittable).init(alloc) };
}

pub fn deinit(self: Self) void {
    for (self.objects.items) |obj| {
        obj.deinit();
    }
    self.objects.deinit();
}

pub fn add(self: *Self, object: Hittable) !void {
    try self.objects.append(object);
}

pub fn clear(self: *Self) !void {
    self.object.clearRetainingCapacity();
}

pub fn hit(self: Self, interval: Interval, ray: *const Ray) ?Collision {
    var collision: ?Collision = null;
    var closest = interval;

    for (self.objects.items) |object| {
        if (object.collisionAt(closest, ray)) |coll| {
            closest.max = coll.t;
            collision = coll;
        }
    }

    return collision;
}

test add {
    var list = try Self.init(testing.allocator);
    defer list.deinit();

    try testing.expectEqual(0, list.objects.items.len);

    const sphere = Hittable.initSphere(.{ 0, 0, 0 }, 1);
    defer sphere.deinit();
    try list.add(sphere);

    try testing.expectEqual(1, list.objects.items.len);
}
