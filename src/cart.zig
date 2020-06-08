const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const Allocator = mem.Allocator;

const SRAM_SIZE = comptime 16 * 1024;
const EXP_RAM_SIZE = comptime 16 * 1024;

pub const Cart = struct {
    rom: []u8,
    // let's just always assume this is sram for the time being
    sram: []u8,
    exp_ram: []u8,

    pub fn new(allocator: *Allocator, rom_path: []const u8) !Cart {
        // default to 64kb of sram
        var sram = try allocator.alloc(u8, SRAM_SIZE);
        mem.set(u8, sram, 0);

        var exp_ram = try allocator.alloc(u8, EXP_RAM_SIZE);
        mem.set(u8, exp_ram, 0);

        return Cart{
            .rom = try fs.cwd().readFileAlloc(allocator, rom_path, 0xffffffff),
            .sram = sram,
            .exp_ram = exp_ram,
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
