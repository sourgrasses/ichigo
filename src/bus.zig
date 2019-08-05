const std = @import("std");

const mem = @import("mem.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Cart = @import("cart.zig").Cart;
const MemError = @import("mem.zig").MemError;

const MIRROR_MASK = 0x08ffffff;

pub const MemRegion = struct {
    lower_bound: u32,
    upper_bound: u32,
    slice: []u8,

    fn new(lower_bound: u32, upper_bound: u32, slice: []u8) MemRegion {
        return MemRegion{
            .lower_bound = lower_bound,
            .upper_bound = upper_bound,
            .slice = slice,
        };
    }
};

pub const Bus = struct {
    // let's do this as a list we have to traverse for every memory read for
    // now to get things working, but we'll almost definitely need to replace
    // this with a more sped-efficient data structure once we're trying
    // to run things ~at speed~
    regions: ArrayList(MemRegion),

    pub fn new(allocator: *Allocator, cart: *Cart, wram: []u8) Bus {
        var regions = ArrayList(MemRegion).init(allocator);
        defer regions.deinit();

        return Bus{
            .regions = regions,
        };
    }

    fn map_region(self: *Bus, lower_bound: u32, upper_bound: u32, mem_region: []u8) !void {
        const region = MemRegion.new(lower_bound, upper_bound, mem_region);
        try self.regions.append(region);
    }

    fn map_io(self: *Bus, dsio: *ds.Io) void {}

    pub fn get_slice(self: *Bus, offset: usize) ![]u8 {
        const moffset = offset & MIRROR_MASK;

        for (self.regions.toSlice()) |region| {
            if (moffset >= region.lower_bound and moffset < region.upper_bound) {
                return region.slice;
            }
        }

        return MemError.RegionNotFound;
    }

    fn read_word(self: *Bus, offset: usize) !u32 {
        const s = try self.get_slice(offset);
        // use a mask to get the relative offset within the memory region
        const mask = s.len - 1;
        return mem.read_word(s, offset & mask);
    }

    fn read_halfword(self: *Bus, offset: usize) !u16 {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        return mem.read_halfword(s, offset & mask);
    }

    fn read_byte(self: *Bus, offset: usize) !u8 {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        return mem.read_byte(s, offset & mask);
    }

    fn write_word(self: *Bus, offset: usize, val: u32) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        mem.write_word(s, offset & mask, val);
    }

    fn write_halfword(self: *Bus, offset: usize, val: u16) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        mem.write_halfword(s, offset & mask, val);
    }

    fn write_byte(self: *Bus, offset: usize, val: u8) !void {
        const s = try self.get_slice(offset);
        const mask = s.len - 1;
        mem.write_byte(s, offset & mask, val);
    }
};
