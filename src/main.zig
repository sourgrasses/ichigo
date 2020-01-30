const std = @import("std");

pub const sdl = @cImport(@cInclude("SDL2/SDL.h"));

const Allocator = std.mem.Allocator;
const Vb = @import("vb.zig").Vb;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    const args = try std.process.argsAlloc(allocator);

    if (args.len != 2) {
        std.debug.warn("Expected ichigo <rom_path>\n");
        std.process.exit(1);
    }

    const rom_path = args[1];

    var vb = try Vb.new(allocator, rom_path);
    vb.run();
}
