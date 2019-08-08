const std = @import("std");
const mem = std.mem;

const Allocator = std.mem.Allocator;

pub const Vsu = struct {
    dummy_ram: []u8,

    pub fn new(allocator: *Allocator) !Vsu {
        var dummy_ram = try allocator.alloc(u8, 64 * 1024);
        mem.set(u8, dummy_ram, 0);

        return Vsu{
            .dummy_ram = dummy_ram,
        };
    }
};
