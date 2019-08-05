const std = @import("std");
const io = std.io;
const mem = std.mem;

const Allocator = mem.Allocator;

pub const Cart = struct {
    rom: []u8,
    // let's just always assume this is sram for the time being
    sram: []u8,

    pub fn new(allocator: *Allocator, rom_path: []const u8) !Cart {
        // default to 64kb of sram
        var sram = try allocator.alloc(u8, 64 * 1024);
        mem.set(u8, sram, 0);

        return Cart{
            .rom = try io.readFileAlloc(allocator, rom_path),
            .sram = sram,
        };
    }

    pub fn len(self: *Cart) usize {
        return self.rom.len;
    }

    pub fn title(self: *Cart) []const u8 {
        const title_loc = self.len() - 544;
        return self.rom[title_loc .. title_loc + 20];
    }
};
