const std = @import("std");
const root = @import("root.zig");

const Hittable = root.Hittable;
const HittableList = root.HittableList;
const Camera = root.Camera;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = try HittableList.init(allocator);
    try world.add(Hittable.initSphere(.{ 0, 0, -1 }, 0.5));
    try world.add(Hittable.initSphere(.{ 0, -100.5, -1 }, 100));

    const camera = comptime blk: {
        break :blk Camera.init(.{
            .aspect_ratio = 16.0 / 9.0,
            .width = 1920,
            .focal_length = 1.0,
            .viewport_height = 2.0,
        });
    };

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());

    try camera.render(&world, buffered.writer(), true);
    try buffered.flush();
}
